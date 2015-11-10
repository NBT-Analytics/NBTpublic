function [EEG,remove_flag] = eeglabel(EEG, regions, type)


remove_flag = false(size(EEG.event));

if isempty(regions),
    EEG.event = [];
    return;
end
if nargin < 3 || isempty(type),
    type = 'add';
end


% handle regions from eegplot and insert labels
% -------------------------------------
if size(regions,2) > 2,
    regions = regions(:,3:4);
end


switch lower(type),
    
    case 'add',
        % open a window to get the label value
        % --------------------------------------
        uigeom = {[1.5 1];[1.5 1];[1.5 1]};
        uilist = {{'style' 'text' 'string' 'Label for this EEG epoch(s):'} ...
            {'style' 'edit' 'string' ''} ...            
            {'style' 'text' 'string' 'Additional info:'} ...
            {'style' 'edit' 'string' ''} ...
            {'style' 'text' 'string' 'Ignore event durations (set=yes):'} ...
            {'style' 'checkbox' 'string' '' 'value' 0} ...
            };
        guititle = 'Choose a label - eeglabel()';
        result = inputgui( uigeom, uilist, 'pophelp(''eeglabel'')', guititle, [], 'normal');
        
        if isempty(result),          
            return;
        end
        
        label = eval(['''' result{1} '''']);
        info = eval(['''' result{2} '''']);
        ignore_durations = result{3};
        new_event_template = struct('type', [], ...
            'latency', [], ...
            'duration', 1, ...
            'urevent', NaN, ...
            'position', NaN, ...
            'epoch', 1, ...
            'info',[]);        
     
        new_event = repmat(new_event_template, size(regions,1), 1);
        
        for i = 1:size(regions,1),
            new_event(i).type = label;
            new_event(i).latency = round(regions(i,1)-.5);
            if ~ignore_durations,
                new_event(i).duration = regions(i,2)-regions(i,1);               
            end
            new_event(i).info = info;
            new_event(i).epoch = ceil(new_event(i).latency/size(EEG.data,2));
        end
        
        EEG.event = new_event;
        
        % They must be consistent and this displays distracting status msgs
        % EEG = eeg_checkset(EEG,'eventconsistency');
        
    case 'remove',
        if isempty(EEG.event), return; end
        
        for i = 1:size(regions,1),
            first = round(regions(i,1)-.5);
            last = first+round(regions(i,2)-regions(i,1));
            remove_flag = false(1,length(EEG.event));
            for j = 1:length(EEG.event),
                if EEG.event(j).latency > first && EEG.event(j).latency < last,
                    remove_flag(j) = true;
                end
            end
            %EEG.event(remove_flag) = [];
        end        
        
        
    otherwise
        error('eeglabel:unknownType', ...
            'Unknown operation type ''%s''', type);
        
        
end

end
