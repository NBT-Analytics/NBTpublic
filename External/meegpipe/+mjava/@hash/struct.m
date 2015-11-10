function str = struct(obj)


objKeys = keys(obj);
objValues = values(obj);

str = [];
for i = 1:numel(objKeys)
    str.(genvarname(objKeys{i})) = objValues{i};
end


end