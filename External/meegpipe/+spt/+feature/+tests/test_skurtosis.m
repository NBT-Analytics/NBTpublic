function [status, MEh] = test_skurtosis()
% TEST_SKURTOSIS - Tests sgini feature

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
    spt.feature.sgini; 
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% sample feature extraction
try
    
    name = 'sample feature extraction';
    
    % Create sample BSS decomposition
    X = rand(10, 15000); 
    A = rand(10);
    A(:,2) = zeros(10,1);
    A(2,2) = 1;
    myBSS = learn(spt.bss.efica, A*X);
    myBSS = match_sources(myBSS, A);
    
    % Select sparse components
    featVal = extract_feature(spt.feature.skurtosis, myBSS);
   
    [~, I] = max(featVal);
    
    ok( I == 2, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% use nonlinearity
try
    
    name = 'use nonlinearity';
    
    % Create sample BSS decomposition
    X = rand(10, 15000); 
    A = rand(10);
    A(:,2) = zeros(10,1);
    A(2,2) = 1;
    myBSS = learn(spt.bss.efica, A*X);
    myBSS = match_sources(myBSS, A);
    
    % Select sparse components
    myFeat = spt.feature.sgini('Nonlinearity', @(x) x.^2);
    
    testVal = myFeat.Nonlinearity(5);
    
    featVal = extract_feature(myFeat, myBSS);
   
    [~, I] = max(featVal);
    
    ok( I == 2 & testVal == 25, name);
    
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

