function [status, MEh] = test_tgini()
% TEST_TGINI - Tests tgini feature

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
    spt.feature.tgini; 
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Sample feature extraction
try
    
    name = 'Sample feature extraction';
    
    % Create sample physioset
    X = randn(4, 10000); 
    
    X(1,1:10:10000) = 10;
    
    % Select sparse components
    featVal = extract_feature(spt.feature.tgini, [], X);
   
    [~, I] = max(featVal);
    
    ok( I == 1, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Use nonlinearity
try
    
    name = 'use nonlinearity';
    
    % Create sample physioset
    X = randn(4, 10000); 
    
    X(1,1:10:10000) = 10;
    
    % Select sparse components
    myFeat = spt.feature.tgini('Nonlinearity', @(x) x.^2);
    
    testVal = myFeat.Nonlinearity(5);
    
    featVal = extract_feature(myFeat, [], X);
   
    [~, I] = max(featVal);
    
    ok( I == 1 & testVal == 25, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Sample feature extraction from physioset
try
    
    name = 'Sample feature extraction';
    
    % Create sample physioset
    X = randn(4, 10000); 
    
    X(1,1:10:10000) = 10;
    
    data = import(physioset.import.matrix, X);
    
    % Select sparse components
    featVal = extract_feature(spt.feature.tgini, [], data);
   
    [~, I] = max(featVal);
    
    ok( I == 1 & max(abs(data(1,:)-X(1,:))) < 0.01, name);
    
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

