function links = link2rec(recID, varargin)
% LINK2REC - Generate links to recording data
%
% link2rec(recID, 'key', value, ...)
%
% Where
%
% RECID is a valid recording ID. See the documentation of somsds.get for
% information on how to retrieve the list of valid recording IDs.
%
% See system('somsds_link2rec') for more information on accepted key/value
% pairs. Note that when providing numeric ranges, e.g. a range of subjects,
% you should use MATLAB ranges rather than SOMSDS-like ranges. That is,
% instead of using 1..3,9 to indicate the subject set 1,2,3,9, you should
% use a call such as:
%
% link2rec('bcgs', 'subject', [1:3, 9])
%
%
% See also: somsds, get

import mperl.file.spec.rel2abs;
import mperl.split;
import mperl.join;
import mperl.config.inifiles.inifile;
import somsds.get_config;
import mperl.file.spec.catdir;

if nargin < 1 || isempty(recID),
    error('A valid RECID must be provided');
end

if ~ischar(recID) || size(recID,2) ~= numel(recID),
    error('Argument RECID must be a string');
end

% Remove known keys that do not have a value
singleKeys = {'--linknames', '--pipe'};
isSingleKey = cellfun(@(x) ischar(x) && ismember(lower(x), singleKeys),...
    varargin);
singleKeys = varargin(isSingleKey);
varargin(isSingleKey) = [];

% Is SOMSDS available in this system?
localSOMSDS = false;

evalc('status = system(''somsds_link2rec'')');

if isunix && status == 255, %#ok<NODEF>
    localSOMSDS = true;
end
if ~localSOMSDS,
    error('Remote somsds queries are not supported yet');
end

if mod(numel(varargin), 2),
    error('A list key/value pairs was expected');
end
if ~all(cellfun(@(x) ischar(x), varargin(1:2:end))),
    error('Arguments must be key/value pairs where keys are strings');
end

% Default folder is the session folder, if local
isFolderKey = cellfun(@(x) ischar(x) && ~isempty(regexpi(x, '-*folder$')), ...
        varargin(1:2:end));
    
if ~any(isFolderKey),    
    
    folderName =  catdir(pwd, datestr(now, 'yymmdd-HHMMSS'));
    if exist(folderName, 'dir'),
        if numel(dir(folderName) > 2),
            error('Directory %s exists and is not empty', folderName);
        end
    end
    varargin = [varargin {'folder', folderName}];
    
end
    
vals      = 2:2:numel(varargin);
keys      = 1:2:numel(varargin);
varargin(keys) = cellfun(@(x) regexprep(x, '^-*(\w)', '--$1'), ...
    varargin(keys), 'UniformOutput', false);

% Strings must be quoted to prevent problems, e.g. with regexs
isString = cellfun(@(x) ischar(x) && isvector(x), varargin(vals));
varargin(vals(isString)) = cellfun(@(x) ['"' x '"'], ...
    varargin(vals(isString)), 'UniformOutput', false);

% Cell values to strings
isCell  = cellfun(@(x) iscell(x), varargin(vals));
varargin(vals(isCell)) = cellfun(@(x) mperl.join(',', x), ...
    varargin(vals(isCell)), 'UniformOutput', false);

% Numeric values to strings
isNumeric = cellfun(@(x) isnumeric(x) && isvector(x), varargin(vals));
varargin(vals(isNumeric)) = cellfun(@(x) mperl.join(',', x), ...
    varargin(vals(isNumeric)), 'UniformOutput', false);

if ~all(cellfun(@(x) ischar(x), varargin(vals))),
    error('Some parameter values could not be converted to strings');
end

cmd = sprintf('somsds_link2rec %s %s ', recID, ...
    join(' ', [varargin singleKeys]));

% Make the system call
[status, result] = system(cmd);
if status,
    error('Something went wrong during a system call: %s', result);
else
    [~, result] = system([cmd ' --linknames']);
    links = split(char(10), result);
    if ~localSOMSDS,
       % Remove any output produced by the .bashrc/.bash_profile
       isDir = cellfun(@(x) ~isempty(strfind(x, folder)), links);
       links(~isDir) = []; 
    end
end

end
