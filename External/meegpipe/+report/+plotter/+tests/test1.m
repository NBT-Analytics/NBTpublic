function [status, ME] = test1()
% TEST1 - Tests basic functionality

import mperl.file.spec.*;
import report.plotter.*;
import test.simple.ok;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import physioset.plotter.snapshots.*;
import physioset.plotter.psd.*;

MEh     = [];

test.simple.initialize(5);

%% Create a test dir
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


%% create sample plotters
try
    
    name = 'create sample plotters';
    myPlotter1 = snapshots('ScaleFactor', 4);
    myPlotter2 = psd; %#ok<FDEPR>
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% constructor
try
    
    name = 'constructor';
    myReport = plotter(...
        'Plotter', {myPlotter1 myPlotter2}, ...
        'Title',    'Sample report');
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% generate()
try
    
    name = 'generate()'; 
    data = import(physioset.import.matrix, randn(50,20000));
    generate(myReport, data);
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    ME = [MEh ME];
    
end


%% Cleanup
try
    
    name = 'cleanup';
    clear myPlotter1 myPlotter2 myReport myParentReport data ans;
    rmdir(session.instance.Folder, 's');
    session.clear_subsession();
    ok(true, name);
    
catch ME
    ok(ME, name);
end


%% Testing summary
status = test.simple.finalize();


end

