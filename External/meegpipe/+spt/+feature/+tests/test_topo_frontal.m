function [status, MEh] = test_topo_frontal()
% TEST_TOPO_FRONTAL - Tests topo_frontal feature

import mperl.file.spec.*;
import pset.selector.*;
import test.simple.*;
import pset.session;
import misc.rmdir;
import datahash.DataHash;
import filter.bpfilt;

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


%% default constructors
try
    
    name = 'default constructor';
    spt.feature.topo_frontal;    
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% using construction arguments
try
    
    name = 'using construction arguments';
    
    % A string (i.e. a regex)
    myFeat = spt.feature.topo_frontal(...
        'R0', 0.5, ...
        'R1', 0.75, ...
        'SpatialFilter', @(x) mean(x), ...
        'SpatialFilterOrder', 10, ...
        'SpatialFilterMinChannels', 10);  
    
    ok( myFeat.R0 == 0.5 && ...
        myFeat.R1 == 0.75 && ...
        myFeat.SpatialFilter([1 2 6]) == 3 && ...
        myFeat.SpatialFilterOrder == 10 && ...
        myFeat.SpatialFilterMinChannels == 10, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% simple feature extraction
try
    
    name = 'simple feature extraction';
    
    mySens = sensors.eeg.from_template('egi256');
    myImporter = physioset.import.matrix('Sensors', mySens);
    
    X = rand(257, 10)*randn(10, 1000);
    data = import(myImporter, X);
    
    sptObj = learn(spt.pca('RetainedVar', 99.99), data);
    
    myFeat = spt.feature.topo_frontal;
    myFeatVal = extract_feature(myFeat, sptObj, randn(10, 1000), data);
    
    ok( numel(myFeatVal) == 10, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% Cleanup
try
    
    name = 'cleanup';
    clear data X;
    rmdir(session.instance.Folder, 's');
    session.clear_subsession();
    ok(true, name);
    
catch ME
    ok(ME, name);
end

%% Testing summary
status = finalize();

end
