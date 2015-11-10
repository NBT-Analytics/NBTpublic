function [status, MEh] = test_mtimes()
% TEST_MTIMES - Test method mtimes()

import test.simple.*;
import mperl.file.spec.*;
import physioset.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import meegpipe.node.*;

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
    MEh = [MEh ME];
    
end

%% mtimes() with square matrix
try
    
    name = 'mtimes() with square matrix';
    data = import(physioset.import.matrix, rand(5, 100));   
    W = rand(5);  
    dataOrig = data(:,:);    
    origFile = get_datafile(data);   
    data2 = W*data;
    
    ok(...
        max(max(abs(data(:,:) - W*dataOrig))) < 0.001 & ...
        strcmp(get_datafile(data2), origFile), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% mtimes() with square matrix with selections
try
    
    name = 'mtimes() with square matrix with selections';
    data = import(physioset.import.matrix, rand(7, 100));   
    W = rand(5);  
    dataOrig = data(:,:);    
    origFile = get_datafile(data);  
    
    select(data, 1:5);
    data2 = W*data;
    
    ok(...
        all(size(data2) == [5 100]) & ...
        max(max(abs(data(:,:) - W*dataOrig(1:5,:)))) < 0.001 & ...
        strcmp(get_datafile(data2), origFile), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% mtimes() with horizonal matrix
try
    
    name = 'mtimes() with horizonal matrix';
    data = import(physioset.import.matrix, rand(5, 100));
    
    W = rand(3,5);
    
    dataOrig = data(:,:);
    data = W*data;
    
    ok(max(max(abs(data(:,:) - W*dataOrig))) < 0.001, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% mtimes() with horizonal matrix with selections
try
    
    name = 'mtimes() with horizonal matrix with selections';
    data = import(physioset.import.matrix, rand(7, 100));   
    W = rand(3,5);  
    dataOrig = data(:,:);    
    origFile = get_datafile(data);  
    
    select(data, 1:5);
    data2 = W*data;
    
    ok(...
        all(size(data2) == [3 100]) & ...
        max(max(abs(data(:,:) - W*dataOrig(1:5,:)))) < 0.001 & ...
        ~strcmp(get_datafile(data2), origFile), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% mtimes() with vertical matrix
try
    
    name = 'mtimes() with vertical matrix';
    data = import(physioset.import.matrix, rand(5, 100));   
    W = rand(6,5); 
    dataOrig = data(:,:);
    data2 = W*data;
    
    ok(max(max(abs(data2(:,:) - W*dataOrig))) < 0.001, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% mtimes() with vertical matrix with selections
try
    
    name = 'mtimes() with vertical matrix with selections';
    data = import(physioset.import.matrix, rand(7, 100));   
    W = rand(7,5);  
    dataOrig = data(:,:);    
    origFile = get_datafile(data);  
    
    select(data, 1:5);
    data2 = W*data;
    
    ok(...
        all(size(data2) == [7 100]) & ...
        max(max(abs(data(:,:) - W*dataOrig(1:5,:)))) < 0.001 & ...
        ~strcmp(get_datafile(data2), origFile), name);
    
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


