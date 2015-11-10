function data = finalize(obj, data)
% FINALIZE_NODE - Finalizes a processing node
%
% finalize(obj)
%
%
% See also: run, initialize, preprocess, postprocess

import meegpipe.node.globals;
import report.remark;
import misc.rmdir;
import pset.session;

%% Save node output
if obj.Save,
    data = save(obj, data);
end

%% Output report
output_report(obj, data);

%% Remark report (only the top-level node does this!)
if isempty(get_parent(obj)) && obj.GenerateReport,
    report.remark(obj.RootDir_);
end

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

% Rinitialize the report
if ~isempty(get_report(obj)),
    set_report(obj, clone(get_report(obj)));
end

if ~isempty(obj.IOReport),
    obj.IOReport = clone(obj.IOReport);
end

%% Global flag ResetNodes
if isempty(get_parent(obj)),
    
    % This is a top-level node => ensure ResetNodes go back to normal
    globals.set('ResetNodes', false);
    globals.set('FakeID', false);
    
else
    if has_changed_runtime(obj),
        resetNodes = true;
    elseif has_changed_config(obj)
        if globals.get.FakeID,
            warning('abstract_node:FakeID', ...
                'Node configuration has changed but FakeID overrides node reset');
            resetNodes = false;
        else
            resetNodes = true;
        end
    else
        resetNodes = false;
    end
    globals.set('ResetNodes', resetNodes);
end

%% Store runtime params hash
set_static(obj, 'hash', 'runtime', get_hash_code(obj.RunTime_));

fid = get_log(obj, 'timing.csv');
fprintf(fid, '%s\n', datestr(now));

if isempty(get_parent(obj))
    %% Clear session and temporary dir
    session.clear_subsession;
    
    % Doing this can confuse users that are using nodes interactively from
    % the command line. The user may import data using a data importer that
    % has its property 'Temporary' to false, but when wrapping such a
    % importer with a physioset_import node then this code will result in
    % the imported data getting effectively deleted after the
    % physioset_import node has done its job.
    %     if exist(get_tempdir(obj), 'dir'),
    %         rmdir(get_tempdir(obj), 's');
    %     end
end

%% Reset node "uninitialized" again
obj.RootDir_ = '';
obj.Static_  = '';


end