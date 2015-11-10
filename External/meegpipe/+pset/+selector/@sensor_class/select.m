function [data, emptySel, arg] = select(obj, data, remember)

arg = [];

if nargin < 3 || isempty(remember),
    remember = true;
end

if obj.Negated,
    isSelected = true(1, nb_dim(data));
else
    isSelected = false(1, nb_dim(data));
end

sensArray = sensors(data);

%% Selection based on sensor classes
if ~isempty(obj.SensorClass),
    
    [grp, idx] = sensor_groups(sensArray);
    for i = 1:numel(grp)
        
        thisClass = class(grp{i});
        thisClass = regexprep(thisClass, '^.+\.([^\.]+)$', '$1');
        
        if ismember(lower(thisClass), lower(obj.SensorClass))
            
            if obj.Negated,
                isSelected(idx{i}) = false;
            else
                isSelected(idx{i}) = true;
            end
        end
    end
    
end

%% Selection based on sensor types
if ~isempty(obj.SensorType)
    
    typesSel = cellfun(@(x) ismember(lower(x), lower(obj.SensorType)), ...
        types(sensArray));
    
    if obj.Negated,
        
        isSelected(typesSel) = false;
        
        
    else
        
        isSelected(typesSel) = true;
        
    end
    
    
end

if isempty(obj.SensorClass) && isempty(obj.SensorType),
    % select everything
    isSelected = ~isSelected;
end

if ~any(isSelected),
    emptySel = true;    
else
    emptySel = false;
    select(data, isSelected, [], remember);
end



end