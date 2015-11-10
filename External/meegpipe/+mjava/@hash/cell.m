function cArray = cell(obj)
% CELL - Hash conversion to cell array
% 
% cArray = cell(obj)
%
% Where
%
% OBJ is a mjava.hash object
%
% CARRAY is a cell array
%
%
% See also: inifile

if isempty(obj),
    cArray = {};
    return;
end

objKeys = keys(obj);

cArray = [objKeys; values(obj)];

if all(cellfun(@(x) isnumeric(x), objKeys)),
    [~, idx] = sort(cell2mat(objKeys));
    cArray = cArray(:, idx);
end

end