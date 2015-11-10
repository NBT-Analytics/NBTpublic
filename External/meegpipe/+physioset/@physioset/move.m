function obj = move(obj, varargin)
% MOVE -


%% Preliminaries
import misc.process_arguments;
import physioset.physioset;
import mperl.file.spec.catfile;
import pset.session;
import pset.globals;

dataExt             = globals.get.DataFileExt;

verbose             = is_verbose(obj);
verboseLabel        = get_verbose_label(obj);

%% Optional input arguments
opt.path            = [];
opt.datafile        = [];
opt.prefix          = [];
opt.postfix         = [];
opt.overwrite       = true;

[~, opt] = process_arguments(opt, varargin);

if isempty(opt.datafile) && isempty(opt.prefix) && isempty(opt.postfix),
    opt.datafile = [...
        session.instance.tempname ...
        globals.get.DataFileExt ...
        ];
end

[path, name] = fileparts(obj.PointSet.DataFile);

if ~isempty(opt.datafile),
    [path, name] = fileparts(opt.datafile);
end

if ~isempty(opt.path),
    path = opt.path;
end

opt.datafile = catfile(path, [opt.prefix name opt.postfix dataExt]);

if ~opt.overwrite && exist(opt.datafile, 'file'),
    warning('physioset:copy:FileExists', ...
        'File %s already exists. Nothing done!', opt.datafile);
elseif exist(opt.datafile, 'file'),
    delete(opt.datafile);
end

%% Create a copy of the data file
[pathstr, fname] = fileparts(opt.datafile);
if isempty(pathstr),
    new_name = ['.' filesep fname dataExt];    
else
    new_name = [pathstr filesep fname dataExt];
end
if verbose,
    [~, nameIn] = fileparts(obj.PointSet.DataFile);
    [~, nameOut] = fileparts(opt.datafile);
    fprintf([verboseLabel, 'Moving ''%s'' -> ''%s''...'], ...
        nameIn, ...
        nameOut);
    pause(0.01);
end
if exist(new_name, 'file'),
    [pathName, fileName] = fileparts(new_name);
    delete(new_name);
    % Associated header file
    hdrFile = [pathName, filesep, fileName, pset.globals.get.HdrFileExt];
    if exist(hdrFile, 'file'),
        delete(hdrFile);
    end
end
obj.PointSet = move(obj.PointSet, new_name, 'Verbose', false);

if verbose,
    fprintf('[done]\n\n');
    pause(0.01);
end


end
