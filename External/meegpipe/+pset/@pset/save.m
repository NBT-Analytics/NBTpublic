function save(obj, filename)
% SAVE Saves a pset object
%

import pset.globals;

datafileext = globals.get.DataFileExt;
hdrfileext = [datafileext 'h'];

if nargin < 2 || isempty(filename),
    [pathstr, name] = fileparts(obj.DataFile);
    filename = [pathstr filesep name];
end

filename = regexprep(filename, ...
    ['(' hdrfileext '|' datafileext '| .mat)'], '');


% % Copy the associated binary data file to the new location
% if ~strcmp(obj.DataFile, [filename datafileext]),
%     pset_obj = copy(obj, 'DataFile', [filename datafileext]);
%     pset_obj.DataFile = [filename datafileext];
% else
%     pset_obj = obj; 
% end
% 
% pset_obj.HdrFile = [filename hdrfileext];
% 
% save([filename hdrfileext], 'obj');

% Copy the associated binary data file to the new location
if ~strcmp(obj.DataFile, [filename datafileext]),
    obj = copy(obj, 'DataFile', [filename datafileext]);
end
% obj.HdrFile = [filename hdrfileext];
% save([filename hdrfileext], 'obj');
[path name] = fileparts(obj.DataFile);
save([path filesep name hdrfileext], 'obj');

