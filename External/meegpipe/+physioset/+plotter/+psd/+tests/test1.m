function [status, MEh] = test1()
% TEST1 - Tests demo functionality

import mperl.file.spec.*;
import physioset.plotter.psd.*;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;

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
    lowLevelEstimator  = spectrum.welch('Hamming', 1000);
    myEstimator = spectrum2.percentile('Estimator', lowLevelEstimator);
    myConfig    = config('Estimator', myEstimator, 'Folder', PATH);
    ok(strcmpi(get(myConfig, 'Folder'), PATH), name);
    
catch ME
    
    ok(ME, name);
    status = finalize();
    return;

end

%% constructor using config object
try
    
    name = 'constructor using config object';
    myPlotter = psd(myConfig); %#ok<*NASGU>
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    status = finalize();
    return;

end
 
%% constructor skipping config construction
try
    
    name = 'construction without config object';
    myPlotter = psd('Estimator', myEstimator, 'Folder', PATH);
    ok(strcmpi(get_config(myPlotter, 'Folder'), PATH), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% default constructor
try
    
    name = 'set config after construction';
    myPlotter = psd;
    set_config(myPlotter, 'Estimator', myEstimator, 'Folder', PATH);
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
    rmdir(PATH, 's');
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% Testing summary
status = finalize();

