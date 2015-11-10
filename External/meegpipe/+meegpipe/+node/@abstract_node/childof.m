function obj = childof(obj, parent, childIdx)


if nargin < 3 || isempty(childIdx), childIdx = []; end

obj.Parent_ = parent;

obj.NodeIdx_ = childIdx;

if ~isempty(childIdx),
    nodeName = get_full_name(obj);
    nodeName = regexprep(nodeName, '^Node\s\d+: ', '');
    set_name(obj, sprintf('Node %0.2d: %s', childIdx, nodeName));
end

end