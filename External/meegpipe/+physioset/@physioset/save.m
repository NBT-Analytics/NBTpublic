function obj = save(obj, filename)
% SAVE Saves an eegset object
%

import pset.globals;

datafileext = globals.get.DataFileExt;
hdrfileext  = [datafileext 'h'];

if nargin < 2 || isempty(filename),
    [pathstr, name] = fileparts(obj.PointSet.DataFile);
    if numel(pathstr) > 1 && strcmp(pathstr(end), filesep),
        filename = [pathstr name];
    else
        filename = [pathstr filesep name];
    end
end

filename = regexprep(filename, ...
    ['(\' hdrfileext '|\' datafileext '| \.mat)$'], '');

% Copy the associated binary data file to the new location
if ~strcmp(obj.PointSet.DataFile, [filename datafileext]),
    obj = copy(obj, 'DataFile', [filename datafileext]);
end
%obj.PointSet = set_hdrfile(obj.PointSet, [filename hdrfileext]);
[path name] = fileparts(get_datafile(obj));
save([path filesep name hdrfileext], 'obj');


end