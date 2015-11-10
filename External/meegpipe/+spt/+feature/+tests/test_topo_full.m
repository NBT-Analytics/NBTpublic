function [status, MEh] = test_topo_full()
% TEST_TOPO_FULL - Tests topo_full feature extractor

import mperl.file.spec.*;
import pset.selector.*;
import test.simple.*;
import pset.session;
import misc.rmdir;
import datahash.DataHash;
import filter.bpfilt;

MEh     = [];

initialize(4);

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
    
    name = 'default constructor';
    spt.feature.topo_full;
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% sample feature extraction
try
    
    name = 'sample feature extraction';
    
    mySens = sensors.eeg.from_template('egi256');
    myImporter = physioset.import.matrix('Sensors', mySens);
    
    S = randn(10, 1000);
    X = rand(257, 10)*S;
    data = import(myImporter, X);
    
    sptObj = learn(spt.pca('RetainedVar', 99.99), data);
    
    Se = proj(sptObj, X);
    
    myFeat = spt.feature.topo_full;
    [myFeat, myFeatName] = extract_feature(myFeat, sptObj, [], data);
    
    ok( all(var(Se, [], 2) > 0.99 & var(Se, [], 2) < 1.01) & ...
        all(size(myFeat) == [257 10]) & iscell(myFeatName) & ...
        numel(myFeatName) == 257 & strcmp(myFeatName{5}, 'EEG 5'), name);
    
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

