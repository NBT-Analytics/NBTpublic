function str = struct(obj)


%% Properties from abstract_node
mClass = ?report.generic.generic;
str = [];
for i = 1:numel(mClass.Properties)    
    
    propName = mClass.Properties{i}.Name;
    if regexp(propName, '_$'), continue; end
    
    str.(propName) = obj.(propName);    
    
end

%% Properties specific to the object's class
mClass = metaclass(obj);
for i = 1:numel(mClass.Properties)    
    
    propName = mClass.Properties{i}.Name;
    if regexp(propName, '_$'), continue; end
    
    str.(propName) = obj.(propName);    
    
end



end