function mango2hpts(file, varargin)

me = 'MEEGS:mango2hpts';

import MISC.process_arguments;
import MEEGS.mango_roi_read;

keySet = {'-hpts'};

[path, ~, ext] = fileparts(file);

if isempty(ext),
    if exist([file '.nii'], 'file'),
        file = [file '.nii'];
    elseif exist([file '.nii.gz'], 'file'),
        file = [file '.nii.gz'];
    elseif exist([file '.csv'], 'file'),
        file = [file '.csv'];
    end
end
[~, name, ext] = fileparts(file);
if strcmpi(ext, '.gz'),
    gunzip(file, tempdir);
    file = [tempdir name];
end
[~, name, ext] = fileparts(file);
hpts = [path name '.hpts'];

eval(process_arguments(keySet, varargin));

if strcmpi(ext, '.csv'),
    perl('meegs_mangocsv2hpts.pl', file, '-hpts', hpts);    
elseif strcmpi(ext, '.nii') || strcmpi(ext, '.gz'),    
    coords = mango_roi_read(file);
    tmpFile = tempname;
    dlmwrite(tmpFile, coords);     
    perl('meegs_dlm2hpts.pl', tmpFile, '-separator', ',', ...
        '-hpts', hpts, varargin{:});
    movefile([tempdir hpts], '.');    
    
else
    ME = MException(me, 'Unknown file type');
    throw(ME);
end



end