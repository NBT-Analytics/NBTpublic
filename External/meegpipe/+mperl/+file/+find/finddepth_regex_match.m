function list = finddepth_regex_match(root, regex, ignorePath, noDirs, noFiles, negated)
% FIND_REGEX_MATCH - Find files and dirs using regular expression
%
%
%   list = finddepth_regex_match(root, regex, ignorePath, noDirs, noFiles, negated)
%
%
% Where
%
% ROOT is the root directory where the search should start
%
% REGEX is the regular expression that files/dirs should match.
%
% IGNOREPATH is a boolean flag that determines whether the while path
% (IGNOREPATH = false) or only the file/dir name (IGNOREPATH = true) should
% be matched against the provided REGEX.
%
% NODIRS is a flag that indicates whether directories should be allowed to
% match the provided regular expression. If NODIRS is set to true, then
% only files will be allowed to match the regex. By default NODIRS is set
% tu false.
%
% NEGATED is a boolean flag. If set to true, then this function will return
% the list of files/dirs that did not match the provided regular
% expression.
%
% LIST is a cell array containing the list of files and/ord directories
% that match (or did not match, if NEGATED) the provided regular
% expression.
%
% See also: mperl.file.find 


import mperl.perl;
import mperl.split;
import mperl.file.spec.rootdir;

%% Check input
if nargin < 1 || isempty(root),
    root = rootdir;
end

root = strrep(root, '\', '/');

if ~exist(root, 'dir'),
    list = [];
    return;
end

if nargin < 2 || isempty(regex),
    regex = '^[^.].+';
end

if nargin < 3 || isempty(ignorePath),
    ignorePath = true;
end

if nargin < 4 || isempty(noDirs),
    noDirs = false;
end

if nargin < 5 || isempty(noFiles),
    noFiles = false;
end

if nargin < 6 || isempty(negated),
    negated = false;
end

%% Portability issues
if ispc,
    % No idea why this is necessary but otherwise the '^' is ignored in my
    % Windows machine
    regex = strrep(regex, '^', '^^');
    % In case the path contains spaces
    %root = sprintf('"%s"', root);
end

if isunix,
    % At least on my Mac this is necessary, again I should find out why...
    if ~isempty(root) && (root(end) ~= '/'), root = [root '/']; end   
end

%regex = ['"' regex '"'];

if ignorePath, ignorePath = '1'; else ignorePath = 'undef'; end
if noDirs, noDirs = '1'; else noDirs = 'undef'; end
if noFiles, noFiles = '1'; else noFiles = 'undef'; end
if negated, negated = '1'; else negated = 'undef'; end

%% Call Perl
list = perl('+mperl/+file/+find/finddepth_regex_match.pl', root, regex, ...
    ignorePath, noDirs, noFiles, negated);

%% This should be unnecessary but just in case
if isunix,
    list  = strrep(list, '\', '/');
else
    list  = strrep(list, '/', '\');
end

%% Split Perl string into a cell array of strings
splittedValue = split(char(10), list);

if ~isempty(splittedValue), 
    list = splittedValue;
end
    
if isempty(list), list = []; end


end