function [status, MEh] = test_threshold()
% TEST_THRESHOLD - Tests threshold criterion

import test.simple.*;
import pset.session;
import misc.rmdir;
import datahash.DataHash;
import safefid.safefid;

MEh     = [];

initialize(15);

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
    spt.criterion.threshold; 
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% MinCard
try
    
    name = 'MinCard selection';
    
    myCrit = spt.criterion.threshold(...
        'Feature', spt.feature.tkurtosis, ...
        'MinCard', 2);
   
    selected = select(myCrit, [], rand(4, 1000));
    
    ok( numel(find(selected)) == 2, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% fprintf
try
    
    name = 'Max';
    
    myCrit = spt.criterion.threshold(...
        'Feature',  spt.feature.tkurtosis, ...
        'Max',      2);
   
    [~, ~, ~, myCrit] = select(myCrit, [], rand(4, 1000));
    
    tmpFile = [tempname(session.instance) '.txt'];
    fid = safefid.fopen(tmpFile, 'w');
    count = fprintf(fid, myCrit);
    
    ok( count > 0, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% MaxCard
try
    
    name = 'MinCard selection';
    
    myCrit = spt.criterion.threshold(...
        'Feature', spt.feature.tkurtosis, ...
        'MaxCard', 2);
   
    selected = select(myCrit, [], rand(4, 1000));
    
    ok( ~any(selected), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% MaxCard overrides Max
try
    
    name = 'MaxCard overrides Max';
    
    myCrit = spt.criterion.threshold(...
        'Feature',  spt.feature.tkurtosis, ...
        'MaxCard',  2, ...
        'Max',      0);
   
    selected = select(myCrit, [], rand(4, 1000));
    
    ok( numel(find(selected)) == 2, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% MaxCard overrides MinCard
try
    
    name = 'MaxCard overrides Max';
    
    myCrit = spt.criterion.threshold(...
        'Feature',  spt.feature.tkurtosis, ...
        'MaxCard',  2, ...
        'MinCard',  3);
   
    selected = select(myCrit, [], rand(4, 1000));
    
    ok( numel(find(selected)) == 2, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% negated
try
    
    name = 'negated';
    
    myCrit = spt.criterion.threshold('Feature',  spt.feature.tkurtosis);
   
    selected = select(~myCrit, [], rand(4, 1000));
    
    ok( all(selected), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% multiple features
try
    
    name = 'multiple features';
    
    myCrit = spt.criterion.threshold(...
        'Feature',  {spt.feature.tkurtosis, spt.feature.tkurtosis}, ...
        'MaxCard',  2, ...
        'Max',      {0, 0});
   
    selected = select(myCrit, [], rand(4, 1000));
    
    ok( numel(find(selected)) == 2, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% multiple features (cont'd)
try
    
    name = 'multiple features (cont''d)';
    
    myCrit = spt.criterion.threshold(...
        'Feature',  {spt.feature.tkurtosis, spt.feature.thilbert}, ...      
        'Max',      {2, 0});
   
    selected = select(myCrit, [], rand(4, 1000));
    
    ok( numel(find(selected)) == 4, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% multiple features (cont'd)
try
    
    name = 'multiple features (cont''d)';
    
    myCrit = spt.criterion.threshold(...
        'Feature',  {spt.feature.tkurtosis, spt.feature.thilbert}, ...      
        'Max',      {5, .1});
   
    selected = select(myCrit, [], rand(4, 1000));
    
    ok( ~any(selected), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% multiple features - or aggregation
try
    
    name = 'multiple features (cont''d)';
    
    myCrit = spt.criterion.threshold(...
        'Feature', {spt.feature.tkurtosis, spt.feature.thilbert}, ...      
        'Max', {5, .1}, ...
        'SelectionAggregator', @(sel)sum(double(sel),1)>0);
   
    selected = select(myCrit, [], rand(4, 1000));
    
    ok( all(selected), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% or static constructor
try
    
    name = 'or static constructor';
    
    myCrit = spt.criterion.threshold.or(...
        spt.feature.tkurtosis, spt.feature.thilbert, ...      
        'Max', {5, .1});
   
    selected = select(myCrit, [], rand(4, 1000));
    
    ok( all(selected), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% multiple features (cont'd)
try
    
    name = 'multiple features (cont''d)';
    
    myCrit = spt.criterion.threshold(...
        'Feature',  {spt.feature.tkurtosis, spt.feature.thilbert}, ...      
        'Max',      {5, 1});
   
    selected = select(myCrit, [], rand(4, 1000));
    
    ok( ~any(selected), name);
    
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

