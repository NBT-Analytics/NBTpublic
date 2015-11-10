function [status, MEh] = test_hierarchical_bss()
% TEST_HIERARCHICAL_BSS - Test BSS algorithms

import test.simple.*;
import mperl.file.spec.*;
import physioset.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import meegpipe.node.*;

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
    MEh = [MEh ME];
    
end

%% default constructor
try
    
    name = 'default constructor';
    
    obj = spt.bss.hierarchical_bss;
    
    ok(isa(obj, 'spt.spt') & isa(obj, 'spt.bss.hierarchical_bss'), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% real data - pwl criterion
try
    
    name = 'real data - pwl criterion';
    
    data = get_real_data;
    
    myNode = meegpipe.node.bss.pwl;
    
    myCrit = get_config(myNode, 'Criterion');
    myCrit.Max = {10};
    
    myBSS = spt.bss.hierarchical_bss(spt.bss.efica, ...
        'Verbose',              true, ...
        'SelectionCriterion',   myCrit, ...
        'DistanceThreshold',    12, ...
        'ParentSurrogates',     10, ...
        'ChildrenSurrogates',   30);
    
    myPCA = learn(spt.pca('MaxCard', 40, 'RetainedVar', 99.75), data);
    
    pcs = proj(myPCA, data);
    
    myBSS = learn(myBSS, pcs);
    
    error = bprojmat(myBSS)*projmat(myBSS)-eye(size(data,1));
    
    ok(...
        cond(projmat(myBSS)*eye(size(data,1))) < 2 & ...
        max(max(abs(error))) < 0.1, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% random data - dummy criterion
try
    
    name = 'random data - dummy criterion';
    
    mySensors = subset(sensors.eeg.from_template('egi256'), 1:3);
    myImporter = physioset.import.matrix('Sensors', mySensors);
    data =  import(myImporter, rand(3, 10000));
    
    myBSS = spt.bss.hierarchical_bss(spt.bss.efica, 'Verbose', false);
    
    myBSS = learn(myBSS, data);
    
    ics = proj(myBSS, data);
    
    data2 = bproj(myBSS, ics);
    
    error = bprojmat(myBSS)*projmat(myBSS)-eye(size(data,1));
    
    ok(...
        cond(projmat(myBSS)*eye(size(data,1))) < 2 & ...
        max(max(abs(error))) < 0.1 & ...
        max(abs(data(:)-data2(:))) < 0.01, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% reproducibility
try
    
    name = 'reproducibility';
    
    X = import(physioset.import.matrix, rand(3, 15000));
    
    isCool = true;
    for i = 1:10,
        
        obj = spt.bss.hierarchical_bss(spt.bss.jade, 'Verbose', false);
        
        obj = learn(obj, X);
        
        W  = projmat(obj);
        
        A  = bprojmat(learn(obj, X));
        
        obj = clear_state(obj);
        
        A2  = bprojmat(learn(obj, X));
        
        isCool = isCool & rcond(W*A) > rcond(W*A2) & ...
            max(max(abs(W*A-eye(size(X,1))))) < 0.01;
        
    end
    
    ok(isCool, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% Cleanup
try
    
    name = 'cleanup';
    clear data ans;
    rmdir(session.instance.Folder, 's');
    session.clear_subsession();
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Testing summary
status = finalize();

end

function data = get_real_data()

import pset.session;
import mperl.file.spec.catfile;
import mperl.file.spec.catdir;

if exist('20131121T171325_647f7.pseth', 'file') > 0,
    data = pset.load('20131121T171325_647f7.pseth');
else
    % Try downloading the file
    url = 'http://kasku.org/data/meegpipe/20131121T171325_647f7.zip';
    unzipDir = catdir(session.instance.Folder, '20131121T171325_647f7');
    unzip(url, unzipDir);
    fileName = catfile(unzipDir, '20131121T171325_647f7.pseth');
    data = pset.load(fileName);
end
data = copy(data);

end
