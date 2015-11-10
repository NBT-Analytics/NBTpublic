function remark(folder)
% REMARK - Generate HTML report using Remark [1]
%
% remark(folder)
%
% Where
%
% FOLDER is the directory where the Remark sources are located
%
% ## References:
%
%   [1] http://kaba.hilvi.org/remark/remark.htm
%
%
% See also: report


import mperl.config.inifiles.inifile;
import mperl.file.spec.catfile;
import goo.globals;
import meegpipe.root_path;

verbose         = globals.get.Verbose;
verboseLabel    = globals.get.VerboseLabel;

if nargin < 1 || isempty(folder), folder = pwd; end

if isunix,
    quotes = '''';
else
    quotes = '"';
end

[~, msg] = system('remark');
if isempty(regexpi(msg, '^\s+Usage\s')),
    [~, msg] = system('remark.py');
    if isempty(regexpi(msg, '^\W*Usage')) && isunix,
        % Try running bashrc first
        cmd = 'source ~/.bashrc; remark';
        [~, msg] = system(cmd);
        if isunix && isempty(regexpi(msg, '^\W*Usage')),
            cmd = 'source ~/.bashrc; remark.py';
            [~, msg] = system(cmd);
            if isempty(regexpi(msg, 'Usage:\s+remark.py')),
                warning('report:remark:MissingDependency', ...
                    ['Remark is not installed in this system: no '  ...
                    'HTML report will be generated']);
                return;
            else
                cmd = 'source ~/.bashrc; remark.py';
            end
        else
            cmd = 'source ~/.bashrc; remark';
        end
    else
        cmd = 'remark.py';
    end
else
    cmd = 'remark';
end


if verbose,
    fprintf([verboseLabel ...
        'Compiling Remark report ...']);
end

cmd = sprintf('%s %s%s%s %s%s%s -v %s*.png%s %s*.svg%s %s*.txt%s', cmd, ...
    quotes, folder, quotes, quotes, folder, quotes, ...
    quotes,quotes,quotes,quotes,quotes,quotes);

[status, res] = system(cmd);

if status && verbose
    fprintf('[failed, see below]\n\n');
elseif verbose
    fprintf('\n\n');
end

if verbose
    res = strrep(res, char(10), [char(10) char(9) 'system->    ']);
    res = [char(9) 'system->    ' res '\n\n'];
    disp(res);
    fprintf([verboseLabel 'End of Remark output\n\n']);
end

source = catfile(report.root_path, 'remark.css');
target = catfile(folder, 'remark_files', 'remark.css');
[success, msg] = copyfile(source, target);
if ~success,
    warning('remark:UnableToCopyCSS', ...
        'Not able to copy custom CSS settings: %s', msg);
end

end