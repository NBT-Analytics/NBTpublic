function restore_global_state(obj)

import meegpipe.node.globals;
import misc.rmdir;
import pset.session;

%% Restore global variables
fNames = fieldnames(obj.Globals_);
for i = 1:numel(fNames)
    globals.set(fNames{i}, obj.Globals_.(fNames{i}));
end

%% Restore super-global variables
fNames = fieldnames(obj.SuperGlobals_);
for i = 1:numel(fNames)
    goo.globals.set(fNames{i}, obj.SuperGlobals_.(fNames{i}));
end

%% Global flag ResetNodes
if isempty(get_parent(obj)),
    
    % This is a top-level node => ensure ResetNodes go back to normal
    globals.set('ResetNodes', false);
 
else
    
    if has_changed(obj),
        globals.set('ResetNodes', true);
    end
    
end

if isempty(get_parent(obj))
    %% Clear session and temporary dir
    session.clear_subsession;

    if exist(get_tempdir(obj), 'dir'),
        rmdir(get_tempdir(obj), 's');
    end
end

%% Reset node "uninitialized" again
obj.RootDir_ = '';
obj.Static_  = '';


end