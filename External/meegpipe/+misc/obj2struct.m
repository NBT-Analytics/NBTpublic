function strVal = obj2struct(obj)

warning('off', 'MATLAB:structOnObject');
strVal = struct(obj);
strVal.Class_ = class(obj);
warning('on', 'MATLAB:structOnObject');

end