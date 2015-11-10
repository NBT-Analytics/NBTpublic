function [data, dataNew] = process(obj, data, varargin)

import misc.eta;
import misc.epoch_get;
import meegpipe.node.erp.compute_erp_features;
import meegpipe.node.erp.generate_erp_images;
import meegpipe.node.erp.generate_erp_topos;
import report.generic.generic;
import mperl.file.spec.catfile;
import misc.code2multiline;

dataNew = [];

verboseLabel = get_verbose_label(obj);
verbose = is_verbose(obj);

sr = data.SamplingRate;

% Configuration options
evSel           = get_config(obj, 'EventSelector');
off             = get_config(obj, 'Offset');
dur             = get_config(obj, 'Duration');
base            = get_config(obj, 'Baseline');
filtObj         = get_config(obj, 'Filter');
peakLatRange    = get_config(obj, 'PeakLatRange');
avgWindow       = get_config(obj, 'AvgWindow');
minMax          = get_config(obj, 'MinMax');
channels        = get_config(obj, 'Channels');
trialsFiltObj   = get_config(obj, 'TrialsFilter');

ev = get_event(data);

numEvents = numel(ev);
if verbose,
    fprintf([verboseLabel 'Dataset contains %d events...\n\n'], numEvents);
end

if ~isempty(ev),
    ev = select(evSel, ev);
    if verbose,
        fprintf([verboseLabel 'Selected %d/%d events...\n\n'], ...
            numel(ev), numEvents);
    end
end

if isempty(ev),
    warning('erp:NoEvents', ...
        'I found no events for ERP computation');
    return;
end

% Set event properties
if ~isempty(dur),
    ev = set(ev, 'Duration', round(dur*sr));
end
if ~isempty(off),
    ev = set(ev, 'Offset',   round(off*sr));
else
    off = unique(get(ev, 'Offset'));
end

% Write event properties to log file
evLogName = [get_name(data) '_events.log'];
fid = get_log(obj, evLogName);
fprintf(fid, ev);

rep = get_report(obj);
print_title(rep, 'Data processing report', get_level(rep) + 1);

print_paragraph(rep, 'Selected events: [%s][evlog]', ...
    evLogName);
print_link(rep, ['../' evLogName], 'evlog');

dur = unique(get(ev, 'Duration'));

if numel(dur) > 1 || numel(off) > 1,
    error('erp:MultipleEventDurations', ...
        'Data epochs of multiple durations or offsets are not supported');
end

if dur < eps,
   % By setting duration to 0 the user is telling us to not compute the ERP. 
   % Maybe she is interested in getting only the characteristics of the
   % ERP-generating events.
   if verbose,
       fprintf([verboseLabel ...
           'ERP of duration 0 -> no ERP will be computed\n\n']);
   end
   return;
end

wv      = nan(size(data,1), dur);
wvStd   = nan(size(data,1), dur);

if verbose,
    fprintf([verboseLabel 'Computing average ERPs...']);
    tinit = tic;
    clear +misc/eta;
end

sens        = sensors(data);
sensLabels  = labels(sens);

rawErp = cell(numel(channels), 1);
count  = zeros(1, numel(channels));

for i = 1:size(data,1)

    epochData = epoch_get(data(i,:), ev);
    tmp = reshape(epochData, size(epochData,2), size(epochData,3));

    for j = 1:numel(channels)
        if iscell(channels{j}),
            % It's a cell array of strings
            if ismember(lower(sensLabels(i)), lower(channels{j})),
                if isempty(rawErp{j}),
                    rawErp{j} = tmp;
                else
                    rawErp{j} = rawErp{j} + tmp;
                end
                count(j) = count(j) + 1;
            end
        elseif ischar(channels{j})
            if ~isempty(regexp(sensLabels{i}, channels{j}, 'once')),
                % It's a regular expression
                if isempty(rawErp{j}),
                    rawErp{j} = tmp;
                else
                    rawErp{j} = rawErp{j} + tmp;
                end
                count(j) = count(j) + 1;
            end
        end
    end

    wv(i,:)      = mean(tmp, 2)';
    wvStd(i,:)   = std(tmp, 0, 2);
    if verbose,
        eta(tinit, size(data,1), i);
    end

end

for i = 1:numel(rawErp),
    if ~isempty(rawErp{i}),
        if count(i) < eps,
            error('Something is really wrong here...');
        end
        rawErp{i} = rawErp{i}./count(i);
    end
end

if any(count < 1),
    emptyList = regexprep(num2str(find(count<1)), '\s+', ', ');
    error('The following channel sets are empty: %s', emptyList);
end

obj.ERPSensorsImgIdx = channels;

if verbose,
    fprintf('\n\n');
    clear +misc/eta;
end

%% Baseline correction
if ~isempty(base)

    onset      = round(-off*sr);
    first      = max(1, 1 + onset + round(base(1)*sr));
    last       = min(onset + round(base(2)*sr), size(wv,2));
    baseVal    = mean(wv(:, first:last), 2);
    wv         = wv - repmat(baseVal, 1, size(wv, 2));

    % Do the same for the raw ERPs of selected channels
    for i = 1:numel(rawErp)
        if isempty(rawErp{i}), continue; end
        baseVal   = mean(rawErp{i}(first:last,:));
        rawErp{i} = rawErp{i} - repmat(baseVal, size(rawErp{i}, 1), 1);
    end

end

obj.ERPWaveform = wv;
obj.ERPSensors  = sensors(data);

%% Filtering across time
if ~isempty(filtObj),

    filtObj      = set_verbose(filtObj, false);
    wv = filtfilt(filtObj, wv);
    % We filter the raw ERPs as well, before plotting the ERP images
    if verbose && numel(rawErp) > 1,
        fprintf([verboseLabel 'Filtering raw ERPs from %d channel sets...'], ...
            numel(rawErp));
        clear +misc/eta;
    end
    for i = 1:numel(rawErp)
        if isempty(rawErp{i}), continue; end
        rawErp{i} = filtfilt(filtObj, rawErp{i}')';
        if verbose && numel(rawErp) > 1,
            eta(tinit, numel(rawErp), i);
        end
    end
    if verbose && numel(rawErp) > 1,
        fprintf('\n\n');
        clear +misc/eta;
    end

end

%% Filtering across trials
if ~isempty(trialsFiltObj)
    trialsFiltObj      = set_verbose(trialsFiltObj, false);

    % We filter the raw ERPs as well, before plotting the ERP images
    if verbose && numel(rawErp) > 1,
        fprintf([verboseLabel 'Filtering raw ERPs across trials from ' ...
            '%d channel sets...'], numel(rawErp));
        clear +misc/eta;
    end
    for i = 1:numel(rawErp)
        rawErp{i} = filtfilt(trialsFiltObj, rawErp{i});
        if verbose && numel(rawErp) > 1,
            eta(tinit, numel(rawErp), i);
        end
    end
    if verbose && numel(rawErp) > 1,
        fprintf('\n\n');
        clear +misc/eta;
    end
end

%% Compute channel stats
if verbose,
    clear +misc/eta;
    tinit = tic;
    fprintf([verboseLabel 'Computing ERP features...']);
end

obj.ERPFeatures = cell(1, numel(rawErp));
logFile = cell(1, numel(rawErp));
setStats = nan(numel(rawErp), 3);
for j = 1:numel(rawErp)
    if isempty(rawErp{j}), continue; end

    stats = nan(size(rawErp{j}, 2), 4);
    stats(:,1) = 1:size(stats,1);
    for i = 1:size(rawErp{j}, 2)

        out = compute_erp_features(rawErp{j}(:, i), ...
            'LatRange',     peakLatRange*1e3, ...
            'AvgWindow',    avgWindow*1e3, ...
            'MinMax',       minMax, ...
            'SamplingRate', sr, ...
            'PreStimulus',  -off*1e3);
        stats(i, 2) = out.latency;
        stats(i, 3) = out.amplitude;
        stats(i, 4) = out.avg_amplitude;

        if verbose,
            eta(tinit, size(rawErp{j}, 2), i);
        end

    end
    obj.ERPFeatures{j} = stats;

    % Print to log file
    logFile{j}  = [get_name(data) '_erp_stats_set' num2str(j) '.log'];
    fid = get_log(obj, logFile{j});

    if ~fid.Valid,
        warning('erp:LogWrite', ...
            'I could not open log file ''%s'': skipping', logFile{j});
        continue;
    end
    if j == 1,
        fprintf(fid, 'trial,latency,amplitude,avg_amplitude\n');
    end
    fprintf(fid, '%d,%.3f,%.3f,%.3f\n', stats');

    % Peak latency for the ERP images
    allSetsLogFile = [get_name(data) '_erp_stats.log'];
    fid = get_log(obj, allSetsLogFile);
    out = compute_erp_features(mean(rawErp{j},2), ...
        'LatRange',     peakLatRange*1e3, ...
        'AvgWindow',    avgWindow*1e3, ...
        'MinMax',       minMax, ...
        'SamplingRate', sr, ...
        'PreStimulus',  -off*1e3);
    setStats(j, 1) = out.latency;
    setStats(j, 2) = out.amplitude;
    setStats(j, 3) = out.avg_amplitude;
    if j == 1,
        fprintf(fid, 'channel_set,latency,amplitude,avg_amplitude\n');
    end
    fprintf(fid, '%d,%.3f,%.3f,%.3f\n', j, setStats(j,:));
end

%% Save ERP info in a binary .mat file
matFile = catfile(get_full_dir(obj), 'erp.mat');
erp.waveform = obj.ERPWaveform;
erp.features = obj.ERPFeatures;
erp.sensors  = obj.ERPSensors; 
erp.latency  = setStats(:,1);
erp.amplitude = setStats(:,2);
erp.avg_amp  = setStats(:,3);
erp.channel_groups = channels;%#ok<STRNU>
save(matFile, 'erp');

print_paragraph(rep, 'To load the ERP to MATLAB''s workspace:');
print_paragraph(rep, '[[Code]]:');

code = sprintf('erpInfo = load(''%s'')', matFile);
code = code2multiline(code, [], char(9));
fprintf(rep, '%s\n\n', code);

if verbose,
    fprintf('\n\n');
    clear +misc/eta;
end

%% Generate the report
print_paragraph(rep, ...
    'See below the log with the ERP features for all channel sets:');
print_paragraph(rep, '[%s][proclog]', allSetsLogFile);
print_link(rep, ['../' allSetsLogFile], 'proclog');

print_paragraph(rep, ...
    'See below the processing logs for all trials in each channel set:');
for i = 1:numel(logFile)
    print_paragraph(rep, ['[%s][proclog' num2str(i) ']'], logFile{i});
    print_link(rep, ['../' logFile{i}], ['proclog' num2str(i)]);
end

if do_reporting(obj),
    time = round(linspace(1e3*off, 1e3*(dur/sr+off), dur));

    % ERP images report
    if verbose,
        fprintf([verboseLabel 'Generating ERP images...\n\n']);
    end
    erpImgRep = generic('Title', 'ERP images');
    erpImgRep = childof(erpImgRep, rep);
    initialize(erpImgRep);

    print_paragraph(rep, 'Below a list of graphical reports:');

    print_link2report(rep, erpImgRep);

    print_paragraph(erpImgRep, ...
        ['Due to a still unresolved bug, the images below will not ' ...
        'display correctly when clicking on them. To zoom in a specific ' ...
        'image, right click and select ''Open link in new tab''']);

    generate_erp_images(erpImgRep, channels, rawErp, time, setStats(:, 1), ...
        setStats(:, 2));

    % Generate ERP topographies report
    if verbose,
        fprintf([verboseLabel 'Generating ERP topographies...']);
    end

    topoRep = generic('Title', 'ERP topograhy');
    topoRep = childof(topoRep, rep);
    initialize(topoRep);

    print_link2report(rep, topoRep);

    % Peak time in samples:
    peakSample = nan(1, size(setStats,1));
    for i = 1:size(setStats,1),
        tmp = find(time(:) >= setStats(i,1), 1, 'first');
        if isempty(tmp),
            peakSample(i) = NaN;
        else
            peakSample(i) = tmp;
        end
    end

    [~, idx] = unique(peakSample);
    doTopo = intersect(find(~isnan(peakSample)), idx);

    if any(doTopo),
        generate_erp_topos(topoRep, sens, wv(:, peakSample(doTopo)), ...
            wvStd(:, peakSample(doTopo)), setStats(doTopo,1));
    end
    if is_verbose(obj),
        fprintf('\n\n');
    end

else

    % Mostly for debugging, leave it
    fprintf([verboseLabel ...
        'Reporting feature is off: not generating report\n\n']);

end


end