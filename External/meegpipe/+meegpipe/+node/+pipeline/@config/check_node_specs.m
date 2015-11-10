function bool = check_node_specs(specs)

import meegpipe.node.pipeline.pipeline;

if iscell(specs) && isempty(specs), bool = true; return; end

isBranch = cellfun(@(x) iscell(x), specs);
isNode   = cellfun(@(x) isa(x, 'meegpipe.node.node'), specs);

if all(isBranch | isNode),
    bool = true;
else
    bool = false;
    return;
end

branchIdx = find(isBranch);

for i = 1:numel(branchIdx),
    bool = bool & pipeline.check_node_specs(specs{branchIdx(i)});
end



end