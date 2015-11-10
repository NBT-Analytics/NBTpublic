function str = struct(obj)


ignore = {'IOReport'};

%% Properties from abstract_node
mClass = ?meegpipe.node.abstract_node;
str = [];
for i = 1:numel(mClass.Properties)
    
    propName = mClass.Properties{i}.Name;
    if regexp(propName, '_$'), continue; end
    isIgnore = cellfun(@(x) ~isempty(regexp(propName, x, 'once')), ignore);
    if any(isIgnore), continue; end
    
    
    str.(propName) = obj.(propName);
    
end

%% Properties specific to the object's class
mClass = metaclass(obj);
for i = 1:numel(mClass.Properties)
    
    propName = mClass.Properties{i}.Name;
    if regexp(propName, '_$'), continue; end
    
    if strcmpi(mClass.Properties{i}.GetAccess, 'private') || ...
            strcmpi(mClass.Properties{i}.SetAccess, 'private')
        continue;
    end
    
    str.(propName) = obj.(propName);
    
end



end