function [status, MEh] = test_sample_epochs()
% TEST_SAMPLE_EPOCHS - Tests sample_epochs feature

import mperl.file.spec.*;
import pset.selector.*;
import test.simple.*;
import pset.session;
import misc.rmdir;
import datahash.DataHash;
import filter.bpfilt;

MEh     = [];

initialize(6);

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
    spt.feature.sample_epochs;
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% more epochs than data length
try
    
    name = 'more epochs than data length';
    
    X = randn(4, 10000);    
    
    X(2,:) = .20*X(2,:) + sin(2*pi*(1/1000)*(1:size(X,2)));
    data = import(physioset.import.matrix, X);
  
    myFeat = spt.feature.sample_epochs(spt.feature.filter_fit.lasip, ...
        'EpochDur', 2000, ...
        'NbEpochs', 100);
    
    featVal = extract_feature(myFeat, [], data);
   
    [~, I] = max(featVal);
    
    ok( I == 2, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% less epochs than data length
try
    
    name = 'more epochs than data length';
    
    X = randn(4, 10000);    
    
    X(2,:) = .20*X(2,:) + sin(2*pi*(1/1000)*(1:size(X,2)));
    data = import(physioset.import.matrix, X);
  
    myFeat = spt.feature.sample_epochs(spt.feature.filter_fit.lasip, ...
        'EpochDur', 1000, ...
        'NbEpochs', 5);
    featVal = extract_feature(myFeat, [], data);
   
    [~, I] = max(featVal);
    
    ok( I == 2, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% epochDur > data duration
try
    
    name = 'epochDur > data duration';
    
    X = randn(4, 10000);    
    
    X(2,:) = .20*X(2,:) + sin(2*pi*(1/1000)*(1:size(X,2)));
    data = import(physioset.import.matrix, X);
  
    myFeat = spt.feature.sample_epochs(spt.feature.filter_fit.lasip, ...
        'EpochDur', 50000, ...
        'NbEpochs', 5);
    warning('off', 'sample_epochs:NotEnoughData');
    featVal = extract_feature(myFeat, [], data);
    warning('on', 'sample_epochs:NotEnoughData');
   
    [~, I] = max(featVal);
    
    ok( I == 2, name);
    
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

