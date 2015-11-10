function obj = from_struct(strArray)
% FROM_STRUCT - Construction from a struct
%
% evArray = from_struct(strArray)
%
% Where
%
% STRARRAY is a struct array, such as those used by the Fieldtrip or EEGLAB
% toolboxes.
%
% EVARRAY is an equivalent array of event objects.
%
% See also: from_fieldtrip, from_eeglab


import physioset.event.event;

if isempty(strArray),
    obj = [];
    return;
end

obj = repmat(event, size(strArray));

fnames = fieldnames(strArray(1));

fnamesU = cellfun(@(x) [upper(x(1)) x(2:end)], fnames, ...
    'UniformOutput', false);

builtinFields = fieldnames(event);

builtinFields = setdiff(builtinFields, {'Type', 'Latency', 'Meta', 'Duration'});

for i = 1:length(fnames)
    
    switch lower(fnamesU{i}),
        
        case 'type',
            for j = 1:length(strArray)
                obj(j).Type = strArray(j).(fnames{i});
            end
            
        case 'latency',
            % EEGLAB's latency field does not always contain integers
            for j = 1:length(strArray)
                obj(j).Sample = 1+floor(strArray(j).(fnames{i}));
            end
            
        case 'meta',
            
            for j = 1:numel(strArray)
                
                if isstruct(strArray(j).(fnames{i})),
                    metaNames  = fieldnames(strArray(j).(fnames{i}));
                    metaNamesU = cellfun(@(x) [upper(x(1)) x(2:end)], ...
                        metaNames, 'UniformOutput', false);
                    for k = 1:numel(metaNames)
                        obj(j) = set_meta(obj(j), metaNamesU{k}, ...
                            strArray(j).(fnames{i}).(metaNames{k}));
                    end
                end
                
            end 
            
        case 'duration',
            % Fieldtrip events (sometimes?) have 0 duration
            for j = 1:length(strArray)
                obj(j).Duration = max(1, strArray(j).(fnames{i}));
            end
            
        case lower(builtinFields),
            
            for j = 1:length(strArray)
                obj(j) = set(obj(j), fnamesU{i}, strArray(j).(fnames{i}));
            end
            
            
        otherwise,
            for j = 1:length(strArray)
                obj(j) = set_meta(obj(j), fnames{i}, strArray(j).(fnames{i}));
            end
    end
    
end





end