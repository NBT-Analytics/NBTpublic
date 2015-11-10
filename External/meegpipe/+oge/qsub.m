function status = qsub(cmd, varargin)
% qsub - Submits a processing job to OGE
%
% qsub(cmd)
%
% qsub(cmd, 'key', value, ...)
%
%
% Where
%
% CMD is the MATLAB command to be executed
%
%
% ## Commonly used key/value pairs:
%
%       Name : (string) Default: oge.qsub
%           The name of the job. It is a good idea to use a meaningful name
%           so that you can easily localize the text files where OGE stores
%           the messages that your job sends to the standar output and
%           standard error streams. The standard output is stored in a file
%           called ~/[jobName].o[jobNumber] while the standard error
%           messages are stored in ~/[jobName].e[jobNumber]. 
%
%       TempDir: (string) Default: ~/tmp
%           Full path name of the directory where the temporary files will
%           be stored. 
%
%       Cleanup: (logical) Default: true
%           If set to false, the temporary files will not be removed after
%           completion of the job. This option is useful for debugging
%           purposes.
%   
%
% ## Less relevant key/value pairs:
%
%       HMemory :  (scalar) Default: oge.globals.evaluate.HVmem
%           Hard limit on the virtual memory that the job can use. 
%
%       Walltime : (string) Defaut: oge.globals.evaluate.HRt
%           Time that a job can take, formatted as HH:MM:SS
%
%       StdOutPath : (string) Default: ''
%           Path where the standard output and error files should be 
%           created. The actual file names wills be JOB_NAME.oJOB_ID
%           and JOB_NAME.oJOB_ID
%                   
%
% See also: oge



import misc.process_arguments;
import misc.split;
import misc.join;
import oge.tempname;
import mperl.file.spec.catfile;
import goo.globals;
import exceptions.*;

status = true;
verbose = globals.get.Verbose;

if isempty(cmd), return; end

if ~ischar(cmd),
    error('oge:qsub', 'A string is expected as input argument');
end

opt.hmemory     = oge.globals.get.HVmem;
opt.smemory     = [];
opt.walltime    = oge.globals.get.HRt;
opt.queue       = oge.globals.get.Queue;
opt.name        = 'oge.qsub';
opt.cleanup     = true;
opt.tempdir     = oge.globals.get.TempDir;

[~, opt] = process_arguments(opt, varargin);

if isempty(opt.smemory),
    opt.smemory = floor(0.9*opt.hmemory);
end

%% create the necessary dirs

if ~exist(opt.tempdir, 'dir'),
    [success, msg] = mkdir(opt.tempdir);
    if ~success, throw(FailedSystemCall('mkdir', msg)); end
end

%% job names cannot start with a digit
if isempty(regexp(opt.name, '^[^\d]', 'once')),
    opt.name = ['j' opt.name];
end

%% Temporary files
mFile  = tempname(opt.tempdir, '.m');
shFile = tempname(opt.tempdir, '.sh');

%% Create the m-file
fid = fopen(mFile, 'wt');
try
    pathCell = split(':', path);
    newPathCell = pathCell;
    for i = 1:numel(pathCell),
       if newPathCell{i}(1)~='/',
          newPathCell{i} = [pwd '/' newPathCell{i}]; 
       end
    end
    fprintf(fid, 'try\n');    
    fprintf(fid, ...
        ['\t addpath(''' join(''',...\n\t ''', unique(newPathCell)) ''');\n']);
    if strcmp(cmd(end), ';'),
        cmd(end) = [];
    end
    fprintf(fid, ['\t cd ' pwd '\n']);
    cmdSplit = misc.split(';',cmd);
    if isempty(cmdSplit),
        fprintf(fid, ['\t ' cmd ';']);
    else
        fprintf(fid, ['\t ' join(';\n\t ', cmdSplit) ';']);
    end
    
    fprintf(fid, '\n\t exit;\n');
    fprintf(fid, 'catch ME\n');   
    fprintf(fid, ['\t fprintf(''%%s : %%s'', ME.identifier, ' ...
        'ME.message);\n']);
    fprintf(fid, 'disp(getReport(ME));\n');
    fprintf(fid, '\t exit;\n');
    fprintf(fid, 'end\n');
    fclose(fid);
catch ME
    fclose(fid);
    rethrow(ME);
end

%% Create the shell script
fid = fopen(shFile, 'wt');
try
    fprintf(fid, '#!/bin/sh\n');
    % The -nodisplay screws with the reporting...
    fprintf(fid, ...
        sprintf('matlab -nodisplay -nosplash -singleCompThread -r "run(''%s'')"\n', ...
        mFile));
    if opt.cleanup,
        fprintf(fid, 'sleep 10\n');
        fprintf(fid, ['rm ' mFile '\n']);
    end
    fclose(fid);
catch ME
    fclose(fid);
    rethrow(ME);
end
system(sprintf('chmod a+x %s', shFile));

%% Submit the job
qsubCmd = sprintf('qsub -N "%s" -l h_rt=%s -l s_vmem=%.0fG -l h_vmem=%.0fG ', ...
    opt.name, ...
    opt.walltime, ...
    opt.smemory, ...
    opt.hmemory);

if ~isempty(opt.queue),
    qsubCmd = [qsubCmd '-q ' opt.queue ' '];
end

qsubCmd = [qsubCmd shFile];   

[status, res] = system(qsubCmd);
if status,
    throw(FailedSystemCall('qsub', res));
end

%% Print submission summary
if numel(cmd) > 100,
    cmd = [cmd(1:100) '...'];
end

if verbose,
    fprintf([res ' : ' cmd '\n']);
end

status = false;

%% Cleanup
if opt.cleanup,    
    delete(shFile);
end

end