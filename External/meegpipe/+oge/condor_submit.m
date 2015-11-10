function status = condor_submit(cmd, varargin)
% condor_submit - Submits a processing job to HTC Condor
%
% condor_submit(cmd)
%
% condor_submit(cmd, 'key', value, ...)
%
%
% Where
%
% CMD is the MATLAB command to be executed
%
%
% ## Accepted key/value pairs:
%
%       Name: (char) Default: random name.
%           The name of the job.
%
%       StdOut: (char) Default: '$(Process).out'
%           The file to which the standard output produced by the process
%           will be redirected.
%
%       StdErr: (char) Default: '$(Process).error'
%           The file to which the standard error will be redirected.
%
%       MatlabLog: (char) Default: 'matlab.log'
%           The file where MATLAB activity will be logged using diary()
%
%       Log: (char) Default: '$(Process).log'
%           The name of the process log file.
%
%       Cleanup: (logical) Default: true
%           If set to false, the temporary files will not be removed after
%           completion of the job. This option is useful for debugging
%           purposes.
%
%       TempDir: (char) Default: oge.globals.eval.TempDir
%           The directory where the temporary files (e.g. the .submit) file
%           will be stored.
%
% See also: oge



import misc.process_arguments;
import misc.split;
import misc.join;
import misc.get_username;
import misc.get_hostname;
import oge.tempname;
import mperl.file.spec.catfile;
import mperl.file.spec.rel2abs;
import mperl.file.spec.catdir;
import goo.globals;
import exceptions.*;
import safefid.safefid;
import misc.unique_filename;

status = true;
verbose = globals.get.Verbose;

if isempty(cmd), return; end

if ~ischar(cmd),
    error('condor_q:qsub', 'A string is expected as input argument');
end

opt.name        = '';
opt.cleanup     = true;
opt.tempdir     = oge.globals.get.TempDir;
opt.stdout      = '$(Process).out';
opt.stderr      = '$(Process).error';
opt.log         = '$(Process).log';
opt.matlablog   = 'matlab.log';

[~, opt] = process_arguments(opt, varargin);


%% create the necessary dirs

if ~exist(opt.tempdir, 'dir'),
    [success, msg] = mkdir(opt.tempdir);
    if ~success, throw(FailedSystemCall('mkdir', msg)); end
end

%% Temporary files
mFile       = tempname(opt.tempdir, '.m');
shFile      = catfile(opt.tempdir, [opt.name '.sh']);
batFile     = catfile(opt.tempdir, [opt.name '.bat']);
if isempty(opt.name) || exist(shFile, 'file'),
    shFile  = tempname(opt.tempdir, '.sh');
    batFile = tempname(opt.tempdir, '.bat');
end
submitFile  = tempname(opt.tempdir, '.submit');

%% Create the m-file
fid = safefid.fopen(mFile, 'wt');
if isunix,
    pathCell = split(':', path);
else
    pathCell = split(';', path);
end

newPathCell = pathCell;
for i = 1:numel(pathCell),
    if (ispc && isempty(regexp(pathCell{i}, '\w:\\', 'once'))) || ...
            (isunix && ~strcmp(pathCell{1}(1), '/'))
        newPathCell{i} = rel2abs(newPathCell{i});
    end
end
fprintf(fid, 'try\n');
fprintf(fid, '\t diary(''%s'');diary on;\n', unique_filename(opt.matlablog));
fprintf(fid, '\t addpath(''%s'');\n', ...
    join([''',...' char(10) char(9) ''''], unique(newPathCell)));
if strcmp(cmd(end), ';'),
    cmd(end) = [];
end
fprintf(fid, '\tcd %s;\n', pwd);
fprintf(fid, '\t%s;', join([';' char(10) char(9)], misc.split(';',cmd)));
fprintf(fid, '\n\t exit;\n');
fprintf(fid, 'catch ME\n');
fprintf(fid, ['\t fprintf(''%%s : %%s'', ME.identifier, ' ...
    'ME.message);\n']);
fprintf(fid, 'disp(getReport(ME));\n');
fprintf(fid, '\t exit;\n');
fprintf(fid, 'end\n');

%% Create the shell script (or a .bat file in Windows)
if isunix,
    fid = safefid.fopen(shFile, 'wt');
    fprintf(fid, '#!/bin/sh\n');
    if isunix && exist('~/.bashrc', 'file'),
        fprintf(fid, 'source ~/.bashrc\n\n');
    end
else
    fid = safefid.fopen(batFile, 'wt');        
end

matlabBin = catfile(matlabroot, 'bin', 'matlab');

if ispc,
    fprintf(fid, 'matlab -r "run(''%s'');exit;"\n', mFile);   
else
    fprintf(fid, ...
        '%s -nodisplay -nosplash -singleCompThread -r "run(''%s'');exit;"\n', ...
        matlabBin, mFile);
end

if opt.cleanup && isunix,
    % Not sure if this works...
    if isunix,
        fprintf(fid, 'sleep 20\n');
        fprintf(fid, ['rm ' rel2abs(mFile) '\n']);
    else
        fprintf(fid, 'timeout /t 20\n');
        fprintf(fid, 'del %s\n', rel2abs(mFile));
    end
end

if isunix,
    system(sprintf('chmod a+x %s', shFile));
end

%% Create the submit description file
fid = safefid.fopen(submitFile, 'wt');

if isunix,
    jobFile = shFile;
else
    jobFile = batFile;
end

fprintf(fid, [ ...
    '# submit description file\n' ...
    '#\n# Created on %s by user %s, on host %s\n\n' ...
    'run_as_owner = True' ... % See: http://research.cs.wisc.edu/htcondor/manual/v7.6/6_2Microsoft_Windows.html
    'Universe   = vanilla\n\n' ...
    'Executable = %s\n\n' ...
    ], datestr(now), get_username, get_hostname, jobFile);


if ispc,
    fprintf(fid, 'input     = %s\n', mFile);
end

fprintf(fid, [ ...
    'output     = %s\n' ...
    'error      = %s\n\n' ...
    'log        = %s\n\n' ...
    'getenv     = True\n\n' ...
    'Queue' ...
    ], opt.stdout, opt.stderr, opt.log);

%% Submit the job
qsubCmd = sprintf('condor_submit %s ', submitFile);

[status, res] = system(qsubCmd);
if isunix && status,
    qsubCmd = sprintf('source ~/.bashrc; condor_submit %s ', submitFile);
    [status, res2] = system(qsubCmd);
    if status,
        throw(FailedSystemCall('condor_q', [res '\n\n' res2]));
    end
    res = res2;
end

%% Print submission summary
if numel(cmd) > 100,
    cmd = [cmd(1:100) '...'];
end

if verbose,
    fprintf('%s : %s\n', res, cmd);
end

status = false;

%% Cleanup
if opt.cleanup,
    delete(submitFile);
end

end