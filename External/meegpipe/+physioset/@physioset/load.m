function obj = load(filename)
% LOAD - Loads a physioset from a .mat file
%
%
% obj = load(filename)
%
% Where
%
% FILENAME is the full path to the .mat file. Note that filename may have a
% non-standard extension such as 'physioseth'. 
%
%
% See also: physioset. pset


import mperl.file.spec.rel2abs;


filename = rel2abs(filename);

tmp = load(filename, '-mat');

obj = tmp.obj;
[path, name] = fileparts(filename);
[~, ~, extOld] = fileparts(get_datafile(obj));
newDataFile = [path '/' name extOld];
if exist(newDataFile, 'file'),    
    fid = fopen(newDataFile);
    if fid > 0,
        fclose(fid);
        obj.PointSet = set_datafile(obj.PointSet, newDataFile);    
        obj.PointSet = set_hdrfile(obj.PointSet, filename);
    end
end