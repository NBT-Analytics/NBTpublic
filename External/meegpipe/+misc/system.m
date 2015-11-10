function [status, msg] = system(cmd, maxTries, pauseInt)
% system - A robust version of the built-in system()
%
% See also: misc

if nargin < 3 || isempty(pauseInt),
    pauseInt = 10;
end

if nargin < 2 || isempty(maxTries),
    maxTries = 5;
end

numTries = 0;
[status, msg] = system(cmd);
while (~isempty(regexp(msg, '(error|Can''t|can''t)', 'once'))) ...
        && numTries < maxTries
    
    numTries = numTries + 1;
    if (~isempty(regexp(msg, '(error|Can''t|can''t)', 'once'))) ...
            && numTries < maxTries
        warning('system:FailedCommand', ...
            'Command ''%s'' failed. Trying again (#%d) ...', cmd, numTries);
        pause(round(1+rand*(pauseInt-1)));
    end
end

if ~isempty(regexp(msg, '(error|Can''t|can''t)', 'once')),
    error('Failed system call ''%s'': %s', cmd, msg);
end


end