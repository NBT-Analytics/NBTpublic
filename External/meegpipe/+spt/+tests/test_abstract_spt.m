function [status, MEh] = test_abstract_spt()
% TEST_ABSTRACT_SPT - Test basic functionality of abstract_spt

import test.simple.*;
import mperl.file.spec.*;
import physioset.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import meegpipe.node.*;

MEh     = [];

initialize(9);

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

%% match_sources
try
    
    name = 'match_sources';
    
    ics = rand(4,100000);
    A = rand(size(ics,1));
    
    data = A*ics;
    
    myBSS = learn(spt.bss.efica, data);    
   
    myBSS = match_sources(myBSS, A);
    
    icsR = proj(myBSS, data);
    
    ics = ics - repmat(mean(ics,2), 1, size(ics,2));
    ics = ics./repmat(sqrt(var(ics, [], 2)), 1, size(ics, 2));
    
    icsR = icsR - repmat(mean(icsR,2), 1, size(icsR,2));
    icsR = icsR./repmat(sqrt(var(icsR, [], 2)), 1, size(icsR, 2));
    
    corrMat = ics*icsR';
    
    I = nan(1, size(corrMat,1));
    for i = 1:size(corrMat, 1)
       [~, I(i)] = max(corrMat(i,:)); 
    end
    
    ok(all(I == [1 2 3 4]), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% proj/bproj
try
    
    name = 'proj/bproj';
    
    data = sample_data;
    
    myBSS = spt.bss.efica;
    
    myBSS = learn(myBSS, data);
    
    dataR = bproj(myBSS, proj(myBSS, data));
    
    ok(max(abs(data(:) - dataR(:))) < 0.01, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% select_component
try
    
    name = 'select_component';
    
    data = sample_data;
    
    myBSS = spt.bss.efica;
    
    myBSS = learn(myBSS, data);
    
    myBSS = select_component(myBSS, [1 3 4]);
    
    ok(...
        size(projmat(myBSS), 1) == 3 & ...
        size(bprojmat(myBSS), 2) == 3 & ...
        numel(component_selection(myBSS)) == 3  & ...
        all(component_selection(myBSS) == [1 3 4]) & ....
        nb_dim(myBSS) == size(data,1) & ...
        nb_component(myBSS) == 3, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% cascading selections
try
    
    name = 'cascading selections';
    
    data = sample_data;
    
    myBSS = spt.bss.efica;
    
    myBSS = learn(myBSS, data);
    
    myBSS = select_component(myBSS, [1 3 4]);
    
    myBSS = select_component(myBSS, [2 3]);
        
    ok(...
        numel(component_selection(myBSS)) == 2 & ...
        all(component_selection(myBSS) == [3 4]), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% restoring selections
try
    
    name = 'restoring selections';
    
    data = sample_data;
    
    myBSS = spt.bss.efica;
    
    myBSS = learn(myBSS, data);
    
    myBSS = select_component(myBSS, [1 3 4]);
    
    myBSS = select_component(myBSS, [2 3]);
    
    myBSS = restore_selection(myBSS);
        
    ok(...
        numel(component_selection(myBSS)) == 3 & ...
        all(component_selection(myBSS) == [1 3 4]), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% cascading BSS objects
try
    
    name = 'cascading BSS objects';    
    
    A1 = rand(3);
    myBSS1 = learn(spt.bss.efica, A1*rand(3,10000));
    
    A2 = rand(3);
    myBSS2 = learn(spt.bss.efica, A2*rand(3,10000));
    
    A3 = rand(3);
    myBSS3 = learn(spt.bss.efica, A3*rand(3,10000));
    
    myBSS = cascade(myBSS1, myBSS2, myBSS3);
    
    A = bprojmat(myBSS);
    
    W = projmat(myBSS);
    
  
    ok(cond(W*A) < 2, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% backup/restore sensors
try
    
    name = 'backup/restore sensors';
    
    data = sample_data;
    
    myBSS = spt.bss.efica;
    
    myBSS = learn(myBSS, data);
    
    ics = proj(myBSS, data);
    
    sensorsICs = sensors(ics);
    
    dataR = bproj(myBSS, ics);
    
    sensorsR = sensors(dataR);
    
        
    ok(...
        isa(sensorsICs, 'sensors.dummy') & ...
        isa(sensorsR, 'sensors.eeg'), name);
    
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


mySensors = subset(sensors.eeg.from_template('egi256'), 1:5);
myImporter = physioset.import.matrix('Sensors', mySensors);
data =  import(myImporter, rand(5, 10000));

end