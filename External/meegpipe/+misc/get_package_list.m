function [list, dirList] = get_package_list()
% get_package_list - Get list of packages currently in the MATLAB path
%
% [list, dirList] = get_package_list
%
% Where `list` is a cell array with the names of all available packages,
% and `dirList` are the corresponding root directories.
%
% See also: md_help

import misc.split_regex;
import misc.join;
import mperl.file.find.regexpdir;
import misc.eta;

persistent listOut;
persistent dirListOut;

if isempty(listOut),
    fprintf('Building package list (may take a few mins) ...');
else
    list    = listOut;
    dirList = dirListOut;
    return;
end

SKIP_REGEX = {...
    '.+/(\.|@)[^/+]+', ...          % skip class directories and hidden folder
    '(/|\)MATLAB.*R\d\d\d\d' ...    % MATLAB built-ins
    };

pathList = split_regex('(;|:)', strrep(path, filesep, '/'));

allCount = 0;

% Skip some dirs
skip = false(size(pathList));
for j = 1:numel(SKIP_REGEX),
    skip = skip & ...
        cellfun(@(x) ~isempty(regexp(x, SKIP_REGEX{j}, 'once')), pathList);
end
pathList = pathList(~skip);

list = cell(numel(pathList)*5, 1);
dirList = cell(size(list));

tinit = tic;
for i = 1:numel(pathList)   
    
    % skip subdirs of previously searched dirs
    found = false;
    for j = 1:i-1
        if ~isempty(regexp(pathList{i}, ['^' pathList{j}], 'once')),
            found = true;
            break;
        end
    end
    if found, continue; end
    
    % Search below this path for + folders
    subList = regexpdir(pathList{i}, '/\+', false, false, true);
    
    if isempty(subList), continue; end
    
    subList = strrep(subList, filesep, '/');
    
    % Skip hidden folders
    skip = false(size(subList));
    for j = 1:numel(SKIP_REGEX),
    skip = skip | ...
        cellfun(@(x) ~isempty(regexp(x, SKIP_REGEX{j}, 'once')), subList);
    end
    subList = unique(subList(~skip));
    
    % Find package names
    pkgNames = cell(numel(subList)*5, 1);
    pkgDirs  = cell(size(pkgNames));
    
    count = 0;
    for j = 1:numel(subList),
        [~, ~, ~, ~, this] = regexp(subList{j}, '/\+([^+/]+)');
        if ~isempty(this),
            this = cellfun(@(x) x{1}, this, 'UniformOutput', false);
            for k = 1:numel(this)
                count = count + 1;
                pkgNames{count} = join('.', this(1:k));
                [~, ~, ~, ~, parentDir] = ...
                    regexp(subList{j}, ['(.+)/\+' this{k}]); 
                pkgDirs{count}  = [parentDir{1}{1} '/+' this{k}]; 
            end
        end
    end
    
    [pkgNames, I] = unique(pkgNames(1:count));
    pkgDirs = pkgDirs(I);
    list(allCount+1:allCount+numel(pkgNames)) = pkgNames;
    dirList(allCount+1:allCount+numel(pkgNames)) = pkgDirs;
    allCount = allCount + numel(pkgNames);
    misc.eta(tinit, numel(pathList), i);
end

list = list(1:allCount);
dirList = dirList(1:allCount);

listOut = list;
dirListOut = dirList;

fprintf('\n\n');

end
