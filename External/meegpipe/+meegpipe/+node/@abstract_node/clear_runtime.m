function obj = clear_runtime(obj)
% CLEAR_RUNTIME - Clear all runtime parameters
%
% obj = clear_runtime(obj)
%
% This method is to be called during node initialization, if the runtime
% parameters of a previous node run have been invalidated. The latter will
% happen if:
%
% (1) The configuration of the node has changed, i.e. the runtime
% parameters that refer to the previous configuration are now invalid.
%
% (2) The configuration OR the runtime parameters of any previous node have
% changed. In such scenario, the input to the current node is likely to
% change, therefore invalidating the existing runtime parameters.
%
% See also: get_runtime, set_runtime

import mperl.file.spec.catfile;

if ~has_runtime_config(obj),
    return;
end

obj.RunTime_ = [];
iniFile = catfile(get_full_dir(obj), [get_name(obj) '.ini']);
misc.delete(iniFile);

end