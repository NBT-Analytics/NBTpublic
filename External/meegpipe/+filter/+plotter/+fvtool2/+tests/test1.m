function [status, MEh] = test1()
% TEST1 - Tests basic package functionality

import mperl.file.spec.*;
import filter.plotter.fvtool2.*;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import oge.has_oge;

MEh     = [];

initialize(5);

%% Create a new session
try
    
    name = 'create new session';
    warning('off', 'session:NewSession');
    session.instance;
    warning('on', 'session:NewSession');
    hashStr = DataHash(randn(1,100));
    session.subsession(hashStr(1:5));
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    status = finalize();
    return;
    
end


%% default constructor
try
    
    name = 'constructor';
    fvtool2;
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% constructor with config options
try
    
    name = 'construct bad_channels node with BlackBgPlots=true';
    obj  = fvtool2('BlackBgPlots', true);
    
    ok(get_config(obj, 'BlackBgPlots'), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% process sample data
try
    
    name = 'process sample data';
    
    filtObj = filter.lpfilt('fc', 0.5);
    obj  = fvtool2('BlackBgPlots', false, ...
        'Folder', session.instance.Folder);
    
    figNames = plot(obj, filtObj);
    
    fileName = catfile(get_config(obj, 'Folder'), figNames{1}{1});
    
    ok(exist(fileName, 'file') > 0, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end



%% Cleanup
try
    
    name = 'cleanup';
    rmdir(session.instance.Folder, 's');
    session.clear_subsession();
    ok(true, name);
    
catch ME
    ok(ME, name);
end

%% Testing summary
status = finalize();