function [data, dataNew] = process(obj, data, varargin)

import physioset.plotter.snapshots.snapshots;
import physioset.event.std.ecg_ann;
import goo.globals;
import misc.eta;
import meegpipe.node.ecg_annotate.ecg_annotate;
import mperl.join;
import misc.any2str;

dataNew = [];

verbose      = is_verbose(obj);
verboseLabel = get_verbose_label(obj);
origVerboseLabel = globals.get.VerboseLabel;
origVerbose      = globals.get.Verbose;

globals.set('VerboseLabel', verboseLabel);
globals.set('Verbose', verbose);

if is_verbose(obj),
    fprintf([verboseLabel 'Running ecgpuwave ...\n\n']);
end

[info, hrvInfo, evArray] = ecgpuwave(obj, data);

obj.HRVFeatures_ = hrvInfo;

%% Save HRV features to log file
hrvLogFile = 'features.txt';
if verbose,
    fprintf([verboseLabel, ...
        'Saving HRV features to %s ...'], hrvLogFile);
end
% Create a table of features:
% EvSelector | HRV features
hrvFeats = {};
if iscell(hrvInfo),
    isEmpty = cellfun(@(x) isempty(x), hrvInfo);
    notEmpty = find(~isEmpty);
    if ~all(isEmpty),
        hrvFeats = keys(hrvInfo{notEmpty(1)});
    end
elseif ~isempty(hrvInfo),
    hrvFeats = keys(hrvInfo);
end

if isempty(hrvFeats),
    warning('ecg_annotate:NoFeatures', ...
        'No features could be extracted for %s', get_name(data));
else
    hrvFeats = sort(hrvFeats);
    
    nCols = numel(hrvFeats);
    nRows = numel(hrvInfo);
    feat  = nan(nRows, nCols);
    
    if iscell(hrvInfo),
        evFeatName = get_config(obj, 'EventFeatureNames');
        for i = 1:numel(hrvInfo),
            if isempty(hrvInfo{i}),
                continue;
            end
            for j = 1:numel(hrvFeats)
                feat(i, j) = hrvInfo{i}(hrvFeats{j});
            end
        end
    else
        evFeatName = {};
        for j = 1:numel(hrvFeats)
            feat(1, j) = hrvInfo(hrvFeats{j});
        end
    end
    
    fid = get_log(obj, hrvLogFile);
    
    % Print a header and the data values
    formatStr = repmat('%s,', 1, numel(hrvFeats));
    formatStr = [formatStr(1:end-1) '\n'];
    if isempty(evFeatName),
        fprintf(fid, formatStr, hrvFeats{:});
    else
        formatStr = ['%s,' formatStr];
        fprintf(fid, formatStr, join(',', evFeatName), hrvFeats{:});
    end
    formatStr = repmat('%5.3f,', 1, numel(hrvFeats));
    formatStr = [formatStr(1:end-1) '\n'];
    if isempty(evFeatName),
        for i = 1:size(feat,1)
            if all(isnan(feat(i,:))), continue; end
            fprintf(fid, formatStr, feat(i,:));
        end
    else
        evFormatStr = repmat('%s,', 1, numel(evFeatName));
        formatStr   = [evFormatStr formatStr];
        evFeat      = get_config(obj, 'EventFeatures');
        for i = 1:size(feat,1)
            if all(isnan(feat(i,:))), continue; end
            
            evFeatVal = cell(1, numel(evFeat));
            for j = 1:numel(evFeat)
                evFeatVal{j} = any2str(evFeat{j}(evArray{i}));
            end
            fprintf(fid, formatStr, evFeatVal{:}, feat(i,:));
            
        end
    end

    if verbose, fprintf('[done]\n\n'); end
end

%% Reject any event not within the data range
sample = single(info.sample);
notInRange = sample > size(data,2);
info.time(notInRange)   = [];
info.ann(notInRange)    = [];
info.subtyp(notInRange) = [];
info.chan(notInRange)   = [];
info.num(notInRange)    = [];
info.sample(notInRange) = [];
sample(notInRange)      = [];

%% Print ECG annotations to log file
logFile = [get_name(data) '.log'];
fid = get_log(obj, logFile);

if isempty(sample), return; end

if fid.Valid,
    tinit = tic;
    
    if verbose,
        fprintf([verboseLabel 'Writing annotations to %s ...'], logFile);
        clear +misc/eta;
    end
    
    fprintf(fid, '# time,sample,annotation,subtype,num\n');
    iterBy100 = max(1, floor(numel(info.sample)/100));
    for i = 1:numel(info.sample)
        fprintf(fid, '''%s'',%d,%s,%d,%d\n', info.time{i}, info.sample(i), ...
            info.ann{i}, info.subtyp(i), info.num(i));
        if verbose && ~mod(i, iterBy100),
            eta(tinit, numel(info.sample), i);
        end
    end
    
    rep = get_report(obj);
    print_title(rep, 'ECG annotation report', get_level(rep)+1);
    print_paragraph(rep, 'Annotations log: [%s][featureslog]', logFile);
    print_link(rep, ['../' logFile], 'featureslog');
    
    print_paragraph(rep, 'HRV features log: [%s][hrvlog]', hrvLogFile);
    print_link(rep, ['../' hrvLogFile], 'hrvlog');
    
    if verbose,
        eta(tinit, numel(info.sample), numel(info.sample));
    end
else
    warning('ecg_annotate:LogWrite', ...
        'I could not write to log file ''%s''', logFile);
end

%% Add annotation events to physioset
evArray = ecg_ann(sample);
timeVec = get_sampling_time(data, sample);

for i = 1:numel(sample)
    evArray(i) = set(evArray(i), 'Time', timeVec(i));
    evArray(i) = set(evArray(i), 'Type', info.ann{i});
    evArray(i) = set(evArray(i), 'SubType', info.subtyp(i));
    evArray(i) = set(evArray(i), 'Value', info.num(i));
end

add_event(data, evArray);

if is_verbose(obj),
    fprintf(['\n\n' verboseLabel ...
        'Done with QRS detection and ECG delineation\n\n']);
end

%% Generate report
if do_reporting(obj),
    
    if is_verbose(obj),
        fprintf([verboseLabel 'Generating report...']);
    end
    
    % Plot some snapshots
    snapshotPlotter = snapshots(...
        'WinLength', 7, ...
        'ScaleFactor', 3.5, ...
        'NbGoodEpochs', 6);
    
    plotterRep = report.plotter.plotter('Plotter', snapshotPlotter);
    
    plotterRep = embed(plotterRep, rep);
    
    generate(plotterRep, data);
    
    if is_verbose(obj),
        fprintf('[done]\n\n');
    end
    
end


globals.set('VerboseLabel', origVerboseLabel);
globals.set('Verbose', origVerbose);

end