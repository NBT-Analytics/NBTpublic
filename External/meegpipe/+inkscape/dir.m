function fileList = dir(path, regex, noDirs, negated)
% DIR - List directory
%
% fileList = dir(path)
% fileList = dir(path, regex)
% fileList = dir(path, regex, noDirs);
% fileList = dir(path, regex, noDirs, negated)
%
% Where 
%
% PATH is the directory to be listed
%
% FILELIST is a cell array with the names of the files within that
% directory. Note that the . and .. items will not be present in FILELIST.
%
% REGEX is an optional regular expression that will be matched against the
% list of files within PATH. Only the files that match such regular
% expression will be returned in FILELIST.
%
% NODIRS is an optional boolean flag. If set to true, then no directory
% names will be included in FILELIST. By default NODIRS is set to false.
%
% NEGATED is a boolean flag. If set to true, then only the files that DO
% NOT match the provided regex will be returned. Note that if REGEX is not
% provided but NEGATED is set to true, then no files will ever be returned
% by this function.
%
% See also: dir

if nargin < 4 || isempty(negated), 
    negated = false;
end

if nargin < 3 || isempty(noDirs),
    noDirs = false;
end

if nargin < 2 || isempty(regex),
    regex = '.+';
end

% Trivial case
if strcmp(regex, '.+') && negated,
    fileList = {};
    return;
end

fileList = dir(path);

% Remove . and .. and maybe just all directories altogether
if noDirs, 
    toRemove = arrayfun(@(x) x.isdir, fileList); 
else
    toRemove = arrayfun(@(x) ismember(x.name, {'.', '..'}), fileList);
end

fileList(toRemove) = [];

% Convert to cell array
fileList = ...
    struct2cell(rmfield(fileList, setdiff(fieldnames(fileList), 'name')));

% Match the regular expression
if ~strcmp(regex, '.+'),
    noMatch = cellfun(@(x) isempty(regexp(x, regex, 'once')), fileList);
    
    if negated,
        fileList(~noMatch) = [];
    else
        fileList(noMatch) = [];
    end    
    
end



end