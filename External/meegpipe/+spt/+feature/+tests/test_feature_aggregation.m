function [status, MEh] = test_feature_aggregation()
% TEST_FEATURE_AGGREGATION - Tests feature_aggregation feature extractor

import mperl.file.spec.*;
import test.simple.*;
import pset.session;
import misc.rmdir;
import datahash.DataHash;
import pset.selector.sensor_class;

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


%% default and static constructors
try
    
    name = 'default constructor';
    spt.feature.feature_aggregation;
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% construction arguments
try
    
    name = 'construction arguments';   
    obj = spt.feature.feature_aggregation(...
        'Features',     {spt.feature.erp, spt.feature.thilbert}, ...
        'Aggregator',   @(x) mean(x) ...
        );
    
    ok(obj.Aggregator([0 2]) == 1 & ...
        isa(obj.Features{1}, 'spt.feature.erp'), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% sample feature extraction
try
    
    name = 'sample feature extraction';
    
    myFeat = spt.feature.feature_aggregation(...
        'Features',     {spt.feature.tkurtosis, spt.feature.thilbert}, ...
        'Aggregator',   @(x) mean(x) ...
        );
    X = randn(4, 1000);
    feature = extract_feature(myFeat, [], X);
    
    feat1 = extract_feature(spt.feature.tkurtosis, [], X);
    feat2 = extract_feature(spt.feature.thilbert, [], X);    
  
    ok(max(abs(feature - 0.5*feat1 - 0.5*feat2)) < 0.001, name);   
    
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