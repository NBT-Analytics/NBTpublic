function y = copy(obj, varargin)

import pset.pset;
import misc.process_arguments;
import pset.session;

import pset.globals;

dataExt = globals.get.DataFileExt;

opt.datafile        = '';
opt.prefix          = '';
opt.postfix         = '';
opt.temporary       = obj.Temporary;
opt.transposed      = obj.Transposed;
opt.writable        = obj.Writable;

[~, opt] = process_arguments(opt, varargin);

if isempty(opt.datafile) && isempty(opt.prefix) && isempty(opt.postfix),
    opt.datafile = session.instance.tempname;
end

[origPath, origName, origExt] = fileparts(obj.DataFile);
if isempty(opt.datafile),
    opt.datafile = ...
        [origPath filesep opt.prefix origName opt.postfix origExt];
else    
    [newPath, newName] = fileparts(opt.datafile);
    if isempty(newPath) && ~isempty(origPath),
        newPath = origPath;
    end    
    opt.datafile = ...
        [newPath filesep opt.prefix newName opt.postfix dataExt];
end

if exist(opt.datafile, 'file'),
    ME = MException('copy:invalidFile', ...
        'File %s already exists!', opt.datafile); 
    throw(ME);
end

% Create a copy of the data file
[pathstr, new_name] = fileparts(opt.datafile);
if isempty(pathstr),
    new_name = ['.' filesep new_name dataExt];    
else
    new_name = [pathstr filesep new_name dataExt];
end
copyfile(obj.DataFile, new_name);

% Create a pset object associated to the new files
y = pset(new_name, obj.NbDims, ...
    'Temporary',    opt.temporary, ...
    'Transposed',   opt.transposed, ...
    'Writable',     opt.writable, ...
    'Precision',    obj.Precision);

y.PntSelection = obj.PntSelection;
y.DimSelection = obj.DimSelection;

end