function [status, MEh] = test_bss()
% TEST_BSS - Test BSS algorithms

import test.simple.*;
import mperl.file.spec.*;
import physioset.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import meegpipe.node.*;

MEh     = [];

initialize(16);

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

%% cca
try
    
    name = 'cca';
    
    data = sample_data;
    
    center(data);
    
    fc = linspace(0.1, 0.7, size(data,1));
    for i = 1:size(data,1)
        select(data, i);
        filter(filter.lpfilt('fc', fc(i)), data);
        restore_selection(data);
    end
    
    myBSS1 = spt.bss.cca('Delay', 2);
  
    myBSS1 = learn(myBSS1, data);    
    
    error1 = ...
        max(max(abs(bprojmat(myBSS1)*projmat(myBSS1)-eye(size(data,1)))));
    
    myBSS2 = spt.bss.cca('Delay', 2);
  
    myBSS2 = learn(myBSS2, data(:,:));    
    
    error2 = ...
        max(max(abs(bprojmat(myBSS2)*projmat(myBSS2)-eye(size(data,1)))));
    
    error3 = max(max(abs(projmat(myBSS1) - projmat(myBSS2))));
    
    ok(...
        error1 < 0.01 & error2 < 0.01 & error3 < 0.01, ...
        name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% tdsep
try
    
    name = 'tdsep';
    
    data = sample_data;
    
    myBSS = spt.bss.tdsep('Lag', 1:20);
  
    filtBands = linspace(0.01, 1, size(data,1)+1);
    for i = 1:size(data,1)
       warning('off', 'design_filter:VariableGroupDelay');
       filtObj = filter.ellip([filtBands(i) filtBands(i+1)]);
       warning('on', 'design_filter:VariableGroupDelay');
       select(data, i);
       filtfilt(filtObj, data);
       restore_selection(data);
    end    
      
    % Transient state of the filter
    select(data, [], 100:size(data,2));
    myBSS = learn(myBSS, data);    
    
    error = bprojmat(myBSS)*projmat(myBSS)-eye(size(data,1));
    
    ok(...
        cond(projmat(myBSS)*eye(size(data,1))) < 5 & ...
        max(max(abs(error))) < 0.01, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% runica
try
    
    name = 'runica';
    
    data = sample_data;
    
    myBSS = spt.bss.runica;
    
    myBSS = learn(myBSS, data);
    
    error = bprojmat(myBSS)*projmat(myBSS)-eye(size(data,1));
    
    ok(...
        cond(projmat(myBSS)*eye(size(data,1))) < 2 & ...
        max(max(abs(error))) < 0.01, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% reproducibility of runica
try
    
    name = 'reproducibility of runica';
    
    X = rand(3, 35000);
    
    isCool = true;
    for i = 1:10,
        
        obj = spt.bss.fastica('InitGuess', @(x) rand(size(x,1)));
        
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


%% multicombi
try
    
    name = 'multicombi';
    
    data = sample_data;
    
    myBSS = spt.bss.multicombi;
    
    myBSS = learn(myBSS, data);
    
    error = bprojmat(myBSS)*projmat(myBSS)-eye(size(data,1));
    
    ok(...
        cond(projmat(myBSS)*eye(size(data,1))) < 2 & ...
        max(max(abs(error))) < 0.01, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% reproducibility of multicombi
try
    
    name = 'reproducibility of multicombi';
    
    X = rand(3, 35000);
    
    isCool = true;
    
    for i = 1:10,
        
        obj = spt.bss.multicombi;
        
        obj = learn(obj, X);
        
        W  = projmat(obj);
        
        A  = bprojmat(learn(obj, X));
        
        obj = clear_state(obj);
        
        A2  = bprojmat(learn(obj, X));
        
        isCool = isCool & rcond(W*A) >= rcond(W*A2) & ...
            max(max(abs(W*A-eye(size(X,1))))) < 0.01;
        
    end
    
    ok(isCool, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end



%% jade
try
    
    name = 'jade';
    
    data = sample_data;
    
    myBSS = spt.bss.jade;
    
    myBSS = learn(myBSS, data);
    
    error = bprojmat(myBSS)*projmat(myBSS)-eye(size(data,1));
    
    ok(...
        cond(projmat(myBSS)*eye(size(data,1))) < 2 & ...
        max(max(abs(error))) < 0.01, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% fastica
try
    
    name = 'fastica';
    
    data = sample_data;
    
    myBSS = spt.bss.fastica;
    
    myBSS = learn(myBSS, data);
    
    error = bprojmat(myBSS)*projmat(myBSS)-eye(size(data,1));
    
    ok(...
        cond(projmat(myBSS)*eye(size(data,1))) < 2 & ...
        max(max(abs(error))) < 0.01, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% reproducibility of fastica
try
    
    name = 'reproducibility of fastica';
    
    X = rand(3, 15000);
    
    isCool = true;
    for i = 1:10,
        
        obj = spt.bss.fastica('InitGuess', @(data) rand(size(data,1)));
        
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


%% ewasobi
try
    
    name = 'ewasobi';
    
    data = sample_data;
    
    myBSS = spt.bss.ewasobi;
    
    myBSS = learn(myBSS, data);
    
    error = bprojmat(myBSS)*projmat(myBSS)-eye(size(data,1));
    
    ok(...
        cond(projmat(myBSS)*eye(size(data,1))) < 2 & ...
        max(max(abs(error))) < 0.01, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% efica
try
    
    name = 'efica';
    
    data = sample_data;
    
    myBSS = spt.bss.efica;
    
    myBSS = learn(myBSS, data);
    
    error = bprojmat(myBSS)*projmat(myBSS)-eye(size(data,1));
    
    ok(...
        cond(projmat(myBSS)*eye(size(data,1))) < 2 & ...
        max(max(abs(error))) < 0.01, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% reproducibility of efica
try
    
    name = 'reproducibility of efica';
    
    X = rand(3, 15000);
    
    isCool = true;
    for i = 1:10,
        
        obj = spt.bss.efica;
        
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

%% amica
try
    
    name = 'amica';
    
    data = sample_data;
    
    myBSS = spt.bss.amica;
    
    myBSS = learn(myBSS, data);
    
    error = bprojmat(myBSS)*projmat(myBSS)-eye(size(data,1));
    
    ok(...
        cond(projmat(myBSS)*eye(size(data,1))) < 2 & ...
        max(max(abs(error))) < 0.01, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% reproducibility of amica
try
    
    name = 'reproducibility of amica';
    
    X = rand(3, 15000);
    
    isCool = true;
    for i = 1:10,
        
        obj = spt.bss.amica;
        
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


function data = sample_data()


mySensors = subset(sensors.eeg.from_template('egi256'), 1:4);
myImporter = physioset.import.matrix('Sensors', mySensors);
data =  import(myImporter, rand(4, 20000));

end