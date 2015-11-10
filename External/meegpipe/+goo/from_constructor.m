function bool = from_constructor(obj)
% FROM_CONSTRUCTOR - Check whether a constructor call is in the stack
%
% bool = from_constructor(obj)
%
% BOOL is true if the call to from_constructor() is preceded in the stack 
% with a call to the constructor of obj.
%
% See also: misc

st = struct2cell(dbstack('-completenames'));

classDefFilename = [strrep(class(obj), '.', '..?') '.m'];

stFnames = cellfun(@(x) strrep(x, '\', '/'), st(1,:), 'UniformOutput', false);
bool1 = cellfun(@(x) ~isempty(regexp(x, [classDefFilename '$'], 'once')), ...
    stFnames);

stFuncNames = cellfun(@(x) regexprep(x, '.*?([^\.]+)$', '$1'), st(2,:), ...
    'UniformOutput', false);
className = regexprep(class(obj), '.*?([^\.]+)$', '$1');
bool2 = ismember(stFuncNames, className);

bool = any(bool1 & bool2);


end