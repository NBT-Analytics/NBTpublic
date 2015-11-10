function bool = has_changed(obj)
% HAS_CHANGED - True if either runtime params or node config has changed
%
% bool = hash_changed(obj)
%
% Where
%
% BOOL is true, if an only if the runtime parameters of nodes that may
% follow the current node (within a pipeline) are invalid. This may happen
% if either:
%
% (1) The node configuration has changed
% (2) The node runtime parameters have changed
% (2) Either the runtime parameters or the configuration of a previous
%     pipeline node has changed.
%
% See also: has_changed_runtime, has_changed_config


import meegpipe.node.globals;

bool = globals.get.ResetNodes || has_changed_runtime(obj) || ...
    has_changed_config(obj);



end