function [data, dataNew] = process(obj, data, varargin)
% PROCESS - Rejects bad channels
%
% data = process(obj, data)
%
% Where
%
% DATA is a physioset object
%
%
% See also: physioset, bad_channels


import mperl.join;
import report.generic.generic;
import report.object.object;
import meegpipe.node.bad_channels.bad_channels;
import meegpipe.node.globals;

dataNew = [];

verbose = is_verbose(obj);
verboseLabel = get_verbose_label(obj);

%% Find bad channels for each sensor group separately

% Get the stored channel selection
runtimeSel = unique(get_runtime(obj, 'channels', 'reject', true));

% % Select only good samples
% select(data, 1:nb_dim(data), ~is_bad_sample(data));

% Iterate across sensor groups
[sensObj, sensIdx] = sensor_groups(sensors(data));

rep = get_report(obj);

print_title(rep, 'Data processing report', get_level(rep) + 1);

crit = get_config(obj, 'Criterion');

for i = 1:numel(sensObj)
    
    select(data, sensIdx{i});
    sensorClass = regexprep(class(sensObj{i}), '^(.+?)([^\.]+)$', '$2');
    sensorClass = upper(sensorClass);
    sensLabels  = labels(sensObj{i});
    
    firstTime = false;
    
    if isempty(runtimeSel),
        thisUsrSel = [];
    elseif ~iscell(runtimeSel) && all(isnan(runtimeSel))
        thisUsrSel = NaN;
        firstTime = true;
    else
        thisUsrSel = find(ismember(sensLabels, runtimeSel));
    end

    if size(data, 1) > 1 && do_reporting(obj),
        title = sprintf('Sensor group %d: %s', i, sensorClass);
        subReport = generic('Title', title);
        subReport = childof(subReport, rep);
        initialize(subReport);
        print_link2report(rep, subReport);
    else
        subReport = [];
    end
    rejIdx = find_bad_channels(crit, data, subReport);
    
    if ~firstTime
        rejIdx  = thisUsrSel;
    end
    
    %% Report for channels ranks
    print_title(rep, 'Bad channel selection', get_level(rep) + 2);
    
    rejLabels = sensLabels(rejIdx);
    
    rejLabels = cellfun(@(x) ['__' x '__'], rejLabels, ...
        'UniformOutput', false);
    rejLabels = join(', ', rejLabels);
    
    print_paragraph(rep, ...
        'Selected channels for rejection: %s', rejLabels);
    
    %% Generate report
    if has_changed_runtime(obj) && ~firstTime && verbose,
        
        fprintf([verboseLabel ...
            'User selection overrides automatic selection...\n\n']);
        
        print_paragraph(rep, ...
            'The automatic selection has been manually overriden');
        
    end

    %% Update the physioset object
    set_bad_channel(data, rejIdx);
    
    restore_selection(data);
    
end

if ~isempty(rejIdx),
    %% Print list of rejected channels
    msg = sprintf( '%d out of %d sensors (%d%%%%) were rejected', ...
        numel(rejIdx), size(data, 1), round(100*numel(rejIdx)/size(data,1)));
    print_paragraph(rep, msg);
    
    if verbose,
         fprintf([verboseLabel msg ': ' rejLabels '\n\n']);
    end
        
else
    
    print_paragraph(rep, ...
        'No channels were rejected');
    
end


%% Remove the good sample selection

sensLabels = labels(sensors(data));

set_runtime(obj, 'channels', 'reject', sensLabels{is_bad_channel(data)});

end