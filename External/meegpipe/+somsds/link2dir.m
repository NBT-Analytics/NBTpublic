function newDir = link2dir(dirName, newDir)
% link2dir - A wrapper around the Perl script somsds_link2dir
%
% See also: somsds

if nargin < 2 || isempty(newDir),
    newDir = [dirName '_copy'];
end

% Is SOMSDS available in this system?
localSOMSDS = false;

evalc('status = system(''somsds_link2dir'')');

if isunix && status == 255, %#ok<NODEF>
    localSOMSDS = true;
end
if ~localSOMSDS,
    error('Remote somsds queries are not supported yet');
end

% Make the system call
cmd = sprintf('somsds_link2dir %s %s ', dirName, newDir);

[status, result] = system(cmd);
if status,
    error('Something went wrong during a system call: %s', result);
end


end