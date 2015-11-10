function initialize(obj, data)
% INITIALIZE - Initialize processing node
%
% initialize(obj)
%
%
% See also: run, finalize, preprocess, postprocess

import meegpipe.node.globals;
import pset.session;
import exceptions.*;
import mperl.file.spec.catfile;
import mperl.file.spec.rel2abs;
import safefid.safefid;
import misc.any2str;

%% Set the global Verbose mode to match that of this node
if isempty(get_parent(obj)),
    verboseLabel = ['(' get_name(obj) ') '];
else
    verboseLabel = ['(' get_name(get_parent(obj)) ' / ' get_name(obj) ') '];
end
obj.SuperGlobals_.VerboseLabel  = goo.globals.get.VerboseLabel;
goo.globals.set('VerboseLabel', verboseLabel);

verbose                         = is_verbose(obj);
obj.SuperGlobals_.Verbose       = goo.globals.get.Verbose;
goo.globals.set('Verbose', verbose);

%% Set the global GenerateReport variable
obj.Globals_.GenerateReport = globals.get.GenerateReport;
globals.set('GenerateReport', do_reporting(obj));

%% Node root directory
obj.RootDir_ = get_full_dir(obj, data);
obj.SaveDir_ = obj.RootDir_;

if isempty(get_parent(obj)),
    obj.VersionFile_ = catfile(obj.RootDir_, 'meegpipe.version');
end

if ~exist(obj.RootDir_, 'dir'),
    [success, msg] = mkdir(obj.RootDir_);
    if ~success,
        throw(FailedSystemCall('mkdir', msg));
    end
end

% Create a session to store all temporary files
if isempty(get_parent(obj)),   
    session.subsession(get_tempdir(obj), 'Force', true);        
    globals.set('ResetNodes', false);
    % This will prevent has_changed_method_config() to detect any
    % configuration changes. FakeID can thus enforce that user selections
    % in subsequent nodes are not reset despite changes in the 
    % configuration of previous nodes. 
    if ~isempty(obj.FakeID),
        globals.set('FakeID', true);
    end
end

%% Save node object, node input, and meegpipe version
if isempty(get_parent(obj))
    
    fName = catfile(obj.RootDir_, 'node.mat');
    builtin('save', fName, 'obj');
    obj.SavedNode_ = fName;
    
    fName = catfile(obj.RootDir_, 'input.mat');
    builtin('save', fName, 'data');
    obj.SavedInput_ = fName;
  
    fid = safefid.fopen(obj.VersionFile_, 'w');    
    fprintf(fid, meegpipe.version);

end


%% Should the runtime params be invalidated?
obj.RunTime_ = get_runtime_config(obj, true);

if globals.get.ResetNodes,
    clear_runtime(obj);
elseif has_changed_config(obj) 
    % Following nodes' runtime params are invalid
    globals.set('ResetNodes', true);    
  
    if globals.get.FakeID,
        warning('abstract_node:FakeID', ...
            'FakeID prevents node reset at %s', get_name(obj));
    else
        clear_runtime(obj);
    end
end

%% Store node configuration hash
set_static(obj, 'hash', 'config', get_hash_code(get_config(obj)));

fid = get_log(obj, 'timing.csv');
fprintf(fid, 'start_time, end_time\n');
fprintf(fid, '%s,', datestr(now));

%% Initialize node report

% Note: The report needs to be initialized even if reporting if OFF.
% Otherwise things will break if a node of a pipeline (whose reporting is
% OFF) has reporting set to ON.
nodeReport = report.node.node(obj);

set_report(obj, nodeReport);

rep = get_report(obj);

initialize(rep);


end