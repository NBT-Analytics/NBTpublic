function [data, dataNew] = process(obj, data, varargin)

import misc.epoch_get;
import meegpipe.node.spectra.power_ratios;
import report.generic.generic;
import misc.any2str;
import mperl.join;
import meegpipe.node.spectra.spectra;

dataNew = [];

verboseLabel = get_verbose_label(obj);
verbose = is_verbose(obj);

% Configuration options
evSel       = get_config(obj, 'EventSelector');
offset      = get_config(obj, 'Offset');
dur         = get_config(obj, 'Duration');
est         = get_config(obj, 'Estimator');
roi         = get_config(obj, 'ROI');
channels    = get_config(obj, 'Channels');
normalized  = get_config(obj, 'Normalized');
plotterPSD  = get_config(obj, 'PlotterPSD');
plotterTopo = get_config(obj, 'PlotterTopo');

if isa(channels, 'function_handle')
    channels = channels(data);
end
obj.ChannelSets = channels;

if isa(plotterPSD, 'function_handle'),
    plotterPSD = plotterPSD(data.SamplingRate);
end

if isa(est, 'function_handle'),
    est = est(data.SamplingRate);
end

% Select the relevant events
if isempty(evSel),
    ev = physioset.event.event(1,'Duration', size(data,2));
else
    ev = select(evSel, get_event(data));
    if ~isempty(dur),
        ev = set_duration(ev, dur);
    end
    if ~isempty(offset),
        ev = set_offset(ev, offset);
    end
end

if isempty(ev),
    fprintf([verboseLabel ...
        'No events match the criterion, doing nothing here ...']);
end

% Epochs, if any must have the same duration
dur     = unique(get(ev, 'Duration'));
off     = unique(get(ev, 'Offset'));

%% Compute Spectra
if numel(dur) > 1 || numel(off) > 1,
    error('spectra:MultipleEventDurations', ...
        'Data epochs of multiple durations or offsets are not supported');
end

if verbose,
    fprintf([verboseLabel ...
        'Computing spectra for %d epochs of %d samples ...\n\n'], ...
        numel(ev), dur);
end

if ~iscell(channels),
    channels = {channels};
end

obj.Spectra = cell(numel(channels), 1);
for i = 1:numel(channels)
    
    if isnumeric(channels{i}),
        chanSel = pset.selector.sensor_idx(channels{i});
    else
        chanSel = pset.selector.sensor_label(channels{i});
    end
    try
        select(chanSel, data);
    catch ME
        if strcmp(ME.identifier, 'selector:EmptySelection'),
            warning('spectra:EmptySelection', ...
                'No matching sensor for set ''%s''', channels{i});
            continue;
        else
            rethrow(ME);
        end
    end
    
    if verbose,
        fprintf([verboseLabel ...
            'Spectra for channel set #%d (%d channels) ...'], i, ...
            size(data,1));
    end
    
    try
        
        thisData = epoch_get(data, ev);
        if size(thisData, 3) > 1,
            thisData = mat2cell(thisData, size(thisData,1), size(thisData,2), ...
                ones(1, size(thisData,3)));
        else
            thisData = {thisData};
        end
        obj.Spectra{i} = psd(est, thisData{:}, 'Fs', data.SamplingRate);  %#ok<FDEPR>
        obj.SpectraSensors{i} = sensors(data);
        obj.SpectraSensorsIdx{i} = dim_selection(data);
        
    catch ME
        restore_selection(data);
        rethrow(ME);
    end
    
    restore_selection(data);
    
    if verbose,
        fprintf('[done]\n\n');
    end
    
end

%% Compute spectral features
if ~isempty(roi),
    if verbose,
        fprintf([verboseLabel, ...
            'Spectral features for %d channel sets ...'], numel(channels));
    end
    
    for i = 1:numel(channels)
        if isempty(obj.Spectra{i}), continue; end
        
        obj.SpectraFeatures{i} = power_ratios(...
            obj.Spectra{i}, roi, normalized);
    end
    
    if verbose, fprintf('[done]\n\n'); end
    
end

%% Save spectral features to log file
if ~isempty(roi),
    logFile = 'features.txt';
    if verbose,
        fprintf([verboseLabel, ...
            'Saving spectral features to %s ...'], logFile);
    end
    
    % Create a table of features:
    % channelSet | bandSpec
    bandSpec = keys(roi);
    feat  = nan(numel(channels), numel(bandSpec));
    
    for i = 1:numel(channels),
        if isempty(obj.SpectraFeatures{i}), continue; end
        for j = 1:numel(bandSpec)
            feat(i, j) = obj.SpectraFeatures{i}(bandSpec{j});
        end
    end
    
    fid = get_log(obj, logFile);
    
    % Print a header and the data values
    formatStr = repmat('%s,', 1, numel(bandSpec)+1);
    formatStr = [formatStr(1:end-1) '\n'];
    fprintf(fid, formatStr, 'channelset', bandSpec{:});
    formatStr = repmat('%5.3f,', 1, numel(bandSpec));
    formatStr =['%s,' formatStr(1:end-1) '\n'];
    for i = 1:size(feat,1)
        if isempty(obj.SpectraFeatures{i}), continue; end
        chanSetName = spectra.get_channel_set_name(channels{i});
        fprintf(fid,formatStr, chanSetName, feat(i,:));
    end
    
    if verbose, fprintf('\n\n'); end
    
else
    
    return;
    
end


%% Generate report
rep = get_report(obj);
print_title(rep, 'Spectral analysis', get_level(rep) + 1);
print_paragraph(rep, '[%s][features]', logFile);
print_link(rep, ['../' logFile], 'features');

if do_reporting(obj),
    
    if verbose,
        fprintf([verboseLabel 'Generating spectra images...']);
    end
    % Generate PSDs
    spectraRep = generic('Title', 'Spectral densities');
    spectraRep = childof(spectraRep, rep);
    initialize(spectraRep);
    
    print_paragraph(rep, 'Graphical reports:');
    
    print_link2report(rep, spectraRep);
    
    generate_spectra_images(obj, spectraRep, plotterPSD, data);
    
    
    if is_verbose(obj),
        fprintf('\n\n');
    end
    
    % Generate topographies
    if verbose,
        fprintf([verboseLabel 'Generating spectra topographies...\n\n']);
    end
    topoRep = generic('Title', 'Topograhies');
    topoRep = childof(topoRep, rep);
    initialize(topoRep);
    
    print_link2report(rep, topoRep);
    
    generate_spectra_topos(obj, topoRep, plotterTopo, data);
    if is_verbose(obj),
        fprintf('\n\n');
    end
    
else
    
    % Mostly for debugging, leave it
    fprintf([verboseLabel ...
        'Reporting feature is off: not generating report\n\n']);
    
end


end


