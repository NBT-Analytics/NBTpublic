function [status, MEh] = test1()
% TEST1 - Test matrix importer

import mperl.file.spec.*;
import physioset.import.matrix;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;

MEh     = [];

initialize(8);

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
    
    name = 'constructor';
    matrix; 
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% contructor with sampling rate
try
    
    name = 'contructor with sampling rate';
    obj = matrix(1000);
    ok(obj.SamplingRate == 1000, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% import data matrix
try
    
    name = 'import data matrix';
    
    X    = randn(10, 1000);
    data = import(matrix, X);  
    
    ok(max(abs(data(:)-X(:))) < 1e-4, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% import data matrix, setting AutoDestroyMemMap
try
    
    name = 'import data matrix';
    
    X    = randn(10, 1000);
    data = import(matrix('AutoDestroyMemMap', true), X);  
    
    ok(data.PointSet.AutoDestroyMemMap & max(abs(data(:)-X(:))) < 1e-4, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% import multiple matrices
try
    
    name = 'import multiple matrices';
    X    = randn(4, 1000);
    Y    = randn(3, 1000);
    Z    = randn(2, 1000);
    data = import(matrix, X, Y, Z);    
 
    ok(...
        max(abs(data{1}(:)-X(:))) < 1e-4 & ...
        max(abs(data{2}(:)-Y(:))) < 1e-4 & ...
        max(abs(data{3}(:)-Z(:))) < 1e-4, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% specify file name
try
    
    name = 'specify file name';
    
    X    = randn(10, 1000);
    import(matrix(100, 'FileName', 'myfile'), X);  
    
    ok(exist('myfile.pset', 'file') > 0, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Cleanup
try
    
    name = 'cleanup';
    clear data;
    rmdir(session.instance.Folder, 's');
    session.clear_subsession();
    ok(true, name);
    
catch ME
    ok(ME, name);
end

%% Testing summary
status = finalize();