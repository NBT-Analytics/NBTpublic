function [data, dataNew] = process(obj, data, varargin)

import physioset.event.class_selector;
import physioset.plotter.snapshots.snapshots;

SNAPSHOT_DUR = 5;  % in seconds
NB_SNAPSHOTS = 5; % number of boundary snapshots to be plotted (At most)

dataNew = [];

rep = get_report(obj);
print_title(rep, 'Data processing report', get_level(rep) + 1);

mergeWindow = get_config(obj, 'MergeWindow');
mergeWindow = ceil(mergeWindow*data.SamplingRate);

eventSelector = get_config(obj, 'EventSelector');
eventArray = select(eventSelector, get_event(data));

verboseLabel = get_verbose_label(obj);
verbose = is_verbose(obj);

if isempty(eventArray),
    msg = 'No discontinuity events: skipping smoothing';
    if verbose,
        fprintf([verboseLabel msg '\n\n']);
        print_paragraph(rep, msg);
    end
    return;
end

eventArray = set_offset(eventArray, -mergeWindow);
eventArray = set_duration(eventArray, 2*mergeWindow+1);

if is_verbose(obj),
    
    verboseLabel = get_verbose_label(obj);
    
    fprintf( [verboseLabel 'Smoothing ''%s'' on %d boundaries ...'], ...
        get_name(data), numel(eventArray));
    
end

print_title(rep, 'Boundary-marking events', get_level(rep) + 2);
fprintf(rep, eventArray, 'SummaryOnly', true);

data = smooth_transitions(data, eventArray);

if do_reporting(obj),
    % Generate before/after plots at various boundaries
    firstSampl = get_sample(eventArray)+get_offset(eventArray)-...
        round((SNAPSHOT_DUR/2)*data.SamplingRate);
    firstSample = unique(max(1, firstSampl));
    lastSample = firstSample + ceil(SNAPSHOT_DUR*data.SamplingRate);
    lastSample = min(size(data,2), lastSample);
    bndryEpochs = [firstSample(:) lastSample(:)];
    if size(bndryEpochs, 1) > NB_SNAPSHOTS,
       epochIdx = round(linspace(1, size(bndryEpochs, 1), NB_SNAPSHOTS));
       bndryEpochs = bndryEpochs(epochIdx, :);
    end    
    
    snapshotPlotter = snapshots(...
        'MaxChannels',  30, ...
        'Epochs',       bndryEpochs);
    subRep = report.plotter.new(...
        'Plotter',      snapshotPlotter, ...
        'Title',        'Before/after smoothing');
    
    embed(subRep, rep);
    
    print_title(rep, 'Before/after smoothing', get_level(rep) + 2);
    
    set_level(subRep, get_level(rep) + 3);

    % Add events to mark the begin/end of the merge window
    mergeEventArray = [];
    for i = 1:numel(eventArray)
        pos = get_sample(eventArray)+get_offset(eventArray);
        pos = max(1, pos);
        startEv = physioset.event.new(pos, 'Type', 'MergeStart');
        pos = get_sample(eventArray)+get_offset(eventArray)+...
            eventArray(i).Duration;
        pos = min(size(data, 2), pos);
        endEv = physioset.event.new(pos, 'Type', 'MergeEnd');
        mergeEventArray = [mergeEventArray; startEv(:); endEv(:)];         %#ok<AGROW>
    end
    [~, evIdx] = add_event(data, mergeEventArray);
    generate(subRep, data);
    delete_event(data, evIdx);
    
end

if is_verbose(obj)
    
    fprintf('[done]\n\n');
    
end

end