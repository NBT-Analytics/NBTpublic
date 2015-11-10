function nodeList = search_processing_history(data, className, nodeName)
% evClass - Search physioset processing history
%
% nodeList = search_processing_history(data, className, nodeName)
%
% Where
%
% CLASSNAME is the name of the class of the node(s) that we are searching
% for.
%
% NODENAME is the name of the node we are searching for.
%
% NODELIST is a cell array with nodes that match the specificiations. The
% nodes in this list are sorted in inverse chronological order. That is,
% nodes that were more recently applied to the dataset will appear first in
% this list.
%
%
% ## Note:
%
% * Multiple class names or node names can be provided using cell arrays.
%
% See also: physioset

% Documentation: pkg_physioset.txt
% Description: Search nodes in processing history

if nargin < 3 || isempty(nodeName), nodeName = {}; end

if nargin < 2 || isempty(className), className = {}; end

if ischar(nodeName), nodeName = {nodeName}; end

if ischar(className), className = {className}; end

allStrings = isempty(className) | ...
    all(cellfun(@(x) misc.isstring(x), className));

allStrings = allStrings & (isempty(nodeName) | ...
    all(cellfun(@(x) misc.isstring(x), nodeName)));

if ~iscell(nodeName) || ~iscell(className) || ~allStrings, ...
        error('physioset.search_processing_history:InvalidSpec', ...
        'Both the node class(es) and name(s) must be cell arrays of strings');
end

nodeList = get_processing_history(data);

nodeList = flipud(nodeList(:));

if isempty(className),
    classMatch = true(numel(nodeList), 1);
else
    
    classMatch = false(numel(nodeList), 1);
    for i = 1:numel(className),
        classMatch = classMatch | ...
            cellfun(@(x) ~isempty(regexpi(class(x), className{i})), nodeList);
    end
end

if isempty(nodeName),
    nameMatch = true(numel(nodeList), 1);
    
else
    
    nameMatch = false(numel(nodeList), 1);
    for i = 1:numel(nodeName)
        nameMatch = nameMatch | ...
            cellfun(@(x) ~isempty(regexpi(get_name(x), nodeName{i})), nodeList);
    end
end

nodeList = nodeList(classMatch & nameMatch);

end