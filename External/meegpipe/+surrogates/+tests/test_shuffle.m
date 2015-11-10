function [status, MEh] = test_shuffle()
% TEST_SHUFFLE - Test shuffle surrogator

import test.simple.*;
import mperl.file.spec.*;
import physioset.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import meegpipe.node.*;

MEh     = [];

initialize(7);

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
    
    obj = surrogates.shuffle;    
    
    ok(isa(obj, 'surrogates.surrogator'), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% reproducible surrogates from numeric data
try
    
    name = 'reproducible surrogates from numeric data';
    
    data = rand(4, 1000);
    
    obj = surrogates.shuffle('NbPoints', 100);
    
    [data1, obj] = surrogate(obj, data);    
    
    data2 = surrogate(obj, data);
    
    ok(size(data1, 2) == 100 & ...
        max(abs(data2(:)-data1(:))) < 0.01, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% random surrogates
try
    
    name = 'random surrogates';
    
       
    data = rand(4, 1000);
    
    obj = surrogates.shuffle('NbPoints', 100);
    
    data1 = surrogate(obj, data);   
    
    data2 = surrogate(obj, data);
    
    ok(size(data1, 2) == 100 & ...
        max(abs(data2(:)-data1(:))) > 0.01, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% surrogates from physioset
try
    
    name = 'surrogates from physioset';
    
       
    data = import(physioset.import.matrix, rand(4, 1000));
    
    obj = surrogates.shuffle('NbPoints', 100);
    
    surrogate(obj, data);  
    
    data1 = data(:,:);    
    restore_selection(data);
    
    surrogate(obj, data);
    
    data2 = data(:,:);    
    restore_selection(data);
    
    ok(size(data1, 2) == 100 & ...
        max(abs(data2(:)-data1(:))) > 0.01, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% reproducibility of surrogates from physioset
try
    
    name = 'reproducibility of surrogates from physioset';
    
       
    data = import(physioset.import.matrix, rand(4, 1000));
    
    obj = surrogates.shuffle('NbPoints', 100);
    
    [~, obj] = surrogate(obj, data);  
    
    data1 = data(:,:);    
    restore_selection(data);
    
    surrogate(obj, data);
    
    data2 = data(:,:);    
    restore_selection(data);
    
    ok(size(data1, 2) == 100 & ...
        max(abs(data2(:)-data1(:))) < 0.01, name);
    
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

