function [status, MEh] = test_function_handle()
% test_function_handle - Tests function_handle filter

import mperl.file.spec.*;
import filter.*;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;

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
    MEh = [MEh ME];
    status = finalize();
    return;
    
end

%% Default constructors
try
    
    name = 'default constructor';
    function_handle;
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    status = finalize();
    return;
    
end

%% Filtering across rows
try
    
    name = 'filtering across rows';
    data = import(physioset.import.matrix, rand(5,1000));
    myFilter = filter.function_handle(...
        'Dim', 'rows', 'Operator', @(x) zscore(x));
    filter(myFilter, data);
    ok(all(abs(std(data(:,:), [], 2) - 1) < 0.0001), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    status = finalize();
    return;
    
end

%% Filtering across columns
try
    
    name = 'filtering across columns';
    data = import(physioset.import.matrix, rand(5,1000));
    myFilter = filter.function_handle(...
        'Dim', 'cols', 'Operator', @(x) zscore(x));
    filter(myFilter, data);
    ok(all(abs(std(data(:,:), [], 1) - 1) < 0.0001), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    status = finalize();
    return;
    
end

%% Cleanup
try
    
    name = 'cleanup';
    clear data dataCopy;
    rmdir(session.instance.Folder, 's');
    session.clear_subsession();
    ok(true, name);
    
catch ME
    ok(ME, name);
    MEh = [MEh ME];
end

%% Testing summary
status = finalize();