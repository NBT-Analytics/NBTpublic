function [status, MEh] = test1()
% TEST1 - Tests demo functionality

import mperl.file.spec.*;
import physioset.plotter.snapshots.*;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;

MEh     = [];

initialize(7);

%% Create a test dir
try
    
    name = 'create test dir';
    warning('off', 'session:NewSession');
    PATH = catdir(session.instance.Folder, DataHash(randn(1,100)));
    mkdir(PATH);
    warning('on', 'session:NewSession');
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    status = finalize();
    return;
end


%% define plotter config
try
    
    name = 'define plotter config';
    myConfig = config('WinLength', [10 30], 'Folder', PATH);
    ok(strcmpi(get(myConfig, 'Folder'), PATH), name);
    
catch ME
    
    ok(ME, name);
    status = finalize();
    return;

end
 

%% constructor
try
    
    name = 'constructor using config object';
    myPlotter = snapshots(myConfig);
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% constructor skipping config construction
try
    
    name = 'construction without config object';
    myPlotter = snapshots('WinLength', [10 30], 'Folder', PATH);
    ok(strcmpi(get_config(myPlotter, 'Folder'), PATH), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% default constructor
try
    
    name = 'set config after construction';
    myPlotter = snapshots;
    set_config(myPlotter, 'WinLength', [10 30], 'Folder', PATH);
    ok(strcmpi(get_config(myPlotter, 'Folder'), PATH), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% plot sample data
try
    
    name = 'plot sample data';
    myData = import(physioset.import.matrix, randn(250, 10000));
    plot(myPlotter, myData);
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Cleanup
try
    name = 'cleanup';
    clear myData myReport;
    pause(1);
    rmdir(PATH, 's');
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% Testing summary
status = finalize();


end



