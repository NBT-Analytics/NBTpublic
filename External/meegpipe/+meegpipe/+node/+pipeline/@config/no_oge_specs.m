function specs = no_oge_specs(specs)
% NO_OGE_SPECS - Sets OGE property to false for all nodes in specs

import meegpipe.node.pipeline.pipeline;

isNode   = cellfun(@(x) isa(x, 'meegpipe.node.node'), specs);
isBranch = cellfun(@(x) iscell(x), specs);

nodeIdx = find(isNode);
for i = 1:numel(nodeIdx),
    specs{i} = set_oge(specs{i}, false);
end

branchIdx = find(isBranch);
for i = 1:numel(branchIdx)
    specs{i} = pipeline.no_oge_specs(specs{i});
end



end