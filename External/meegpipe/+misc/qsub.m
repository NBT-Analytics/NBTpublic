function jobNumber = qsub(cmd, varargin)
% QSUB - Submits MATLAB jobs to Oracle Grid Engine
%
% Usage:
%
% jobNumber = qsub(cmd)
% qsub(cmd, 'key', value, ...)
%
% Where
%
% CMD is a string with the MATLAB command to be executed. Alternatively,
% CMD can be a cell array of strings with multiple MATLAB commands.
%
% JOBNUMBER is the OGE job number assigned to the submitted job. 
%
%
% ## Optional arguments (as key/value pairs):
%
%       HMemory : Numeric scalar. Default: 10  
%           Maximum virtual memory that a job can take, in Gb. This is a
%           hard limit, meaning that a job will be killed (or will die due
%           to a memory allocation error) if it exceeds this threshold. 
%
%       SMemory : Numeric scalar. Default: [], i.e not applicable
%           Soft limit of virtual memory. If a job exceeds this limit it
%           will get a SIGUSR1 signal. This limit is only meaningful if
%           your programs take advantage of such a signal and attempt to
%           reduce the amount of resources used once the SIGUSR1 is
%           received. 
%
%       Walltime : String. Default: '10:00:00'. 
%           Maximum walltime for the job, as HH:MM:SS.
%
%       Name: String. Default: 'misc.qsub'
%           Name of the job. 
%
% 
% ## Example (assumes Linux operating system):
%
% % Run a never ending job
% jobNumber = misc.qsub('for i=1:Inf, disp(i); end');
%
% % See whether the job is running or still waiting in the queue
% system('qstat');
%
% % See the output so far:
% system(sprintf('cat ~/misc.qsub.o%d', jobNumber));
%
% % kill the job (do this fast or your home folder will become full!)
% system(sprintf('qdel %d', jobNumber));
%
% % Clean up
% delete(sprintf('~/misc.qsub.o%d', jobNumber))
%
% 
% See also: misc


import misc.process_arguments;
import misc.split;
import misc.join;
import misc.globals;
import mperl.file.spec.rel2abs;

if isempty(cmd), return; end

if iscell(cmd),
    cmd  = join(';', cmd);
end

if ~ischar(cmd),
    error('misc:qsub', 'A string is expected as input argument');
end

opt.hmemory     = 10; % in Gbs
opt.smemory     = [];
opt.walltime    = '10:00:00';
opt.queue       = [];
opt.name        = 'misc.qsub';

[~, opt] = process_arguments(opt, varargin);

if isempty(opt.smemory),
    opt.smemory = floor(0.9*opt.hmemory);
end

% Create the m-file
if isunix, 
    mFile = tempname('~');
else
    mFile = tempname;
end
mFile = strrep(mFile, '\', '/');
fid = fopen(mFile, 'w');
try
    if isunix,
        pathCell = split(':', path);
    else
         pathCell = split(';', path);
    end   
    % Take care of relative paths and of backslashes
    for i = 1:numel(pathCell),
       pathCell{i} = rel2abs(pathCell{i});      
       pathCell{i} = strrep(pathCell{i}, '\', '/');
    end
    fprintf(fid, 'try\n');    
    fprintf(fid, ...
        ['addpath(''' join(''',...\n''', unique(pathCell)) ''');\n']);
    if strcmp(cmd(end), ';'),
        cmd(end) = [];
    end
    fprintf(fid, [misc.join(';\n', misc.split(';',cmd)) ';']);
    fprintf(fid, '\nexit;\n');
    fprintf(fid, 'catch ME\n');
    fprintf(fid, 'fprintf(''%%s : %%s'', ME.identifier, ME.message);\n');
    fprintf(fid, 'exit;\n');
    fprintf(fid, 'end\n');
    fclose(fid);
catch ME
    fclose(fid);
    rethrow(ME);
end

% Create the shell script
if isunix,
    shFile = tempname('~');
else
    shFile = tempname;
end
shFile = strrep(shFile, '\', '/');
fid = fopen(shFile, 'w');
try
    fprintf(fid, '#!/bin/sh\n');
    fprintf(fid, ...
        sprintf('matlab -nodisplay -nosplash -singleCompThread < %s\n', mFile));
    fclose(fid);
catch ME
    fclose(fid);
    rethrow(ME);
end
system(sprintf('chmod a+x %s', shFile));

% Submit the job
qsubCmd = sprintf('qsub -N "%s" -l h_rt=%s -l s_vmem=%.0fG -l h_vmem=%.0fG ', ...
    opt.name, ...
    opt.walltime, ...
    opt.smemory, ...
    opt.hmemory);
if ~isempty(opt.queue),
    qsubCmd = [qsubCmd '-q ' opt.queue];
end
qsubCmd = [qsubCmd '< ' shFile];   
[status, res] = system(qsubCmd);
n = regexpi(res, 'Your job (?<jobnb>\d+)', 'Names');
if isempty(n) || ~isfield(n, 'jobnb'),
    jobNumber = NaN;
else
    jobNumber = str2double(n(1).jobnb);    
end
if status,
    ME = MException('misc:qsub:OGEError', ...
        'Something went wrong when submitting the job to OGE:\n %s', ...
        res);
    throw(ME);
end
if numel(cmd) > 100,
    cmd = [cmd(1:100) '...'];
end
fprintf([res ' : ' cmd '\n']);

end