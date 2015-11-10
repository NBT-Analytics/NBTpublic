function [status, msg] = send_ssh_command(url, cmd, usr, pw, maxTries, pauseInt)

if nargin < 6 || isempty(pauseInt),
    pauseInt = 10;
end

if nargin < 5 || isempty(maxTries),
    maxTries = 10;
end

if ispc,
    cmd = sprintf('plink -pw %s %s@%s "%s"', pw, usr, url, cmd);
else
    cmd = sprintf(['sshpass -p ''%s'' ssh -o "%s" ' ...
        '%s@%s "%s"'], pw, 'StrictHostKeyChecking no',usr, url, cmd);
end

status = 127; msg = ''; numTries = 0;
while (status > 0 || ~isempty(regexp(msg, '(error|Can''t|can''t)', 'once'))) ...
        && numTries < maxTries
    [status, msg] = system(cmd);
    numTries = numTries + 1;
    if (status > 0 || ~isempty(regexp(msg, '(error|Can''t|can''t)', 'once'))) ...
            && numTries < maxTries
        warning('send_ssh_command:FailedCommand', ...
            'Command ''%s'' failed, trying again (#%d)', cmd, numTries);
        pause(round(1+rand*(pauseInt-1)));
    end
end

if (status > 0 || ~isempty(regexp(msg, '(error|Can''t|can''t)', 'once')))
    error('Failed remote call to %s: %s', url, msg);
end

end