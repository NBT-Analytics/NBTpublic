function [status, MEh] = test_tstat()
% TEST_TSTAT - Tests topo_stat feature extractor

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

    S = randn(10, 1000);
    
    [myFeat, myFeatName] = extract_feature(spt.feature.tstat, [], S);
    
    ok( isempty(myFeatName) & all(size(myFeat) == size(S')) & ...
        all(myFeat(:,1) == S(1,:)') , name);
    
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

