function [status, MEh] = test_thilbert()
% test_thilbert - Tests thilbert feature

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
    spt.feature.thilbert; 
    spt.feature.thilbert.pwl;
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Sample feature extraction
try
    
    name = 'Sample feature extraction';
    
    X = randn(4, 10000);    
    
    X(2,:) = .20*X(2,:) + sin(2*pi*(1/5)*(1:size(X,2)));
    data = import(physioset.import.matrix, X);
  
    myFilt  = bpfilt('fp', [45 55]/(250/2));
    feat    = spt.feature.thilbert('Filter', myFilt);
    featVal = extract_feature(feat, [], data);
   
    [~, I] = min(featVal);
    
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

