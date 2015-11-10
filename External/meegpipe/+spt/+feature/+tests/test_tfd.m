function [status, MEh] = test_tfd()
% test_tfd - Tests tfd feature

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


%% default constructors
try
    
    name = 'default constructor';
    spt.feature.tfd; 
    spt.feature.tfd.eog;
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% spt.feature.tfd.eog
try
    
    name = 'spt.feature.tfd.eog';
    
    X = randn(4, 10000);  
    data = import(physioset.import.matrix, X);
  
    myFilt  = bpfilt('fp', [4 10]/(data.SamplingRate/2));
    data(2,:) = filter(myFilt, data(2,:));
    
    feat    = spt.feature.tfd.eog;
    featVal = extract_feature(feat, [], data);
   
    [~, I] = min(featVal);
    
    ok( I == 2 & max(abs(data(1,:) - X(1,:))) < 0.01, name);
    
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

