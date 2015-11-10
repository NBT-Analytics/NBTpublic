function [status, MEh] = test_output_components()
% TEST_OUTPUT_COMPONENTS - Tests outputting the estimatting components

import mperl.file.spec.*;
import meegpipe.node.*;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import oge.has_oge;

MEh     = [];

initialize(12);

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

%% construction with Reject=[]
try
    
    name = 'construction with Reject=[]';   
   
    myNode = bss.new('Reject', []);    

    rej = get_config(myNode, 'Reject');
    ok(isempty(rej), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% filtering components
try    

    name = 'filtering components';
    
    X = rand(8, 20000); 
    eegSensors = sensors.eeg.from_template('egi256', 'PhysDim', 'uV');
    eegSensors = subset(eegSensors, 1:32:256);
    
    importer = physioset.import.matrix(250, 'Sensors', eegSensors);
    data = import(importer, X);
    
    myFilter = filter.lpfilt('fc', .5);
    myBSS    = spt.bss.jade('LearningFilter', myFilter);
    
    myCrit = spt.criterion.threshold(spt.feature.tgini, ...
        'MaxCard', 2, 'MinCard', 2);
    
    myNode = bss.new(...
        'BSS',              myBSS, ...
        'Save',             true, ...
        'GenerateReport',   true, ...
        'Reject',           [], ...
        'Criterion',        myCrit, ...
        'Filter',           @(sr) filter.bpfilt('Fp', [0 5;14 60]/(sr/2)));
    
    ics = run(myNode, data);
   
    condition = size(ics, 1) == 2 & isa(sensors(ics), 'sensors.dummy');
    outputFileName = get_output_filename(myNode, data);
    clear data ans;
    
    ok( condition & ...
        exist(outputFileName, 'file') > 0, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% learning filter and saving node output
try    

    name = 'learning filter and saving node output';
    
    X = rand(8, 20000); 
    eegSensors = sensors.eeg.from_template('egi256', 'PhysDim', 'uV');
    eegSensors = subset(eegSensors, 1:32:256);
    
    importer = physioset.import.matrix(250, 'Sensors', eegSensors);
    data = import(importer, X);
    
    myFilter = filter.lpfilt('fc', .5);
    myBSS    = spt.bss.jade('LearningFilter', myFilter);
    
    myCrit = spt.criterion.threshold(spt.feature.tgini, ...
        'MaxCard', 2, 'MinCard', 2);
    
    myNode = bss.new(...
        'BSS',              myBSS, ...
        'Save',             true, ...
        'GenerateReport',   false, ...
        'Reject',           [], ...
        'Criterion',        myCrit);
    
    ics = run(myNode, data);
   
    condition = size(ics, 1) == 2 & isa(sensors(ics), 'sensors.dummy');
    outputFileName = get_output_filename(myNode, data);
    clear data ans;
    
    ok( condition & ...
        exist(outputFileName, 'file') > 0, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% process sample data: simple case
try    
  
    name = 'process sample data: simple case';
    
    X = rand(4, 5000);
   
    eegSensors = sensors.eeg.from_template('egi256', 'PhysDim', 'uV');
   
    eegSensors   = subset(eegSensors, 1:4);
    
    importer = physioset.import.matrix(250, 'Sensors', eegSensors);
    
    data = import(importer, X);
    
    myNode = meegpipe.node.bss.new(...
        'Reject',       [], ...
        'Criterion',    ~spt.criterion.dummy);
    ics = run(myNode, data);    
    
    ok(isa(sensors(ics), 'sensors.dummy'), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% threshold criterion with kurtosis feature
try    
  
    name = 'threshold criterion with kurtosis feature';
    
    X = rand(4, 5000);
    
    warning('off', 'sensors:InvalidLabel');
    eegSensors = sensors.eeg.from_template('egi256', 'PhysDim', 'uV');
    warning('on', 'sensors:InvalidLabel');
    
    eegSensors = subset(eegSensors, 1:4);
    
    importer = physioset.import.matrix(250, 'Sensors', eegSensors);
    
    data = import(importer, X);
    
    myCrit = spt.criterion.threshold(spt.feature.tkurtosis, ...
        'MaxCard', 2, 'MinCard', 2);
    
    myNode = bss.new(...
        'GenerateReport',   true, ...
        'Criterion',        myCrit, ...
        'Reject',           []);
    
    ics = run(myNode, data);
    
    ok(size(ics,1) == 2 & isa(sensors(ics), 'sensors.dummy'), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% multiple sensor groups, bad samples, bad channels
try

    name = 'multiple sensor groups, bad samples, bad channels';
    
    X = rand(10, 20000);
    eegSensors = sensors.eeg.from_template('egi256', 'PhysDim', 'uV');
    
    eegSensors   = subset(eegSensors, 1:32:256);
    dummySensors = sensors.dummy(2);
    allSensors   = sensors.mixed(eegSensors, dummySensors);
    
    importer = physioset.import.matrix(250, 'Sensors', allSensors);
    data = import(importer, X);
    
    set_bad_sample(data, 50:2500);
    set_bad_channel(data, 1:3);
    
    center(data);
    
    myCrit = spt.criterion.threshold(spt.feature.tkurtosis, ...
        'MaxCard', 2, 'MinCard', 2);
    
    myNode = meegpipe.node.bss.new(...
        'Reject',           [], ...
        'GenerateReport',   false, ...
        'Criterion',        myCrit);
    
    ics = run(myNode, data);
    
    ok(size(ics, 1) == 2 & isa(sensors(ics), 'sensors.dummy'), name);
    
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% learning filter and saving node output
try    

    name = 'learning filter and saving node output';
    
    X = rand(8, 20000); 
    eegSensors = sensors.eeg.from_template('egi256', 'PhysDim', 'uV');
    eegSensors = subset(eegSensors, 1:32:256);
    
    importer = physioset.import.matrix(250, 'Sensors', eegSensors);
    data = import(importer, X);
    
    myFilter = filter.lpfilt('fc', .5);
    myBSS    = spt.bss.jade('LearningFilter', myFilter);
    
    myCrit = spt.criterion.threshold(spt.feature.tgini, ...
        'MaxCard', 2, 'MinCard', 2);
    
    myNode = meegpipe.node.bss.new(...
        'BSS',              myBSS, ...
        'Save',             true, ...
        'GenerateReport',   true, ...
        'Reject',           [], ...
        'Criterion',        myCrit);
    
    ics = run(myNode, data);
   
    condition = size(ics, 1) == 2 & isa(sensors(ics), 'sensors.dummy');
    outputFileName = get_output_filename(myNode, data);
    clear data ans;
    
    ok( condition & ...
        exist(outputFileName, 'file') > 0, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% filtering spcs activations
try    

    name = 'filtering spcs activations';
    
    X = rand(8, 20000); 
    eegSensors = sensors.eeg.from_template('egi256', 'PhysDim', 'uV');
    eegSensors = subset(eegSensors, 1:32:256);
    
    importer = physioset.import.matrix(250, 'Sensors', eegSensors);
    data = import(importer, X);
    
    myFilter = filter.hpfilt('fc', .1);
    myCrit   = spt.criterion.threshold(spt.feature.tgini, ...
        'MaxCard', 3, 'MinCard', 3);
    
    myNode = meegpipe.node.bss.new(...
        'Filter',           myFilter, ...
        'Criterion',        myCrit, ...
        'Save',             true, ...
        'GenerateReport',   true, ...
        'Reject',           []);
    
    ics = run(myNode, data);
   
    condition = size(ics, 1) == 3 & isa(sensors(ics), 'sensors.dummy');
    outputFileName = get_output_filename(myNode, data);
    clear data ans ics;
    
    ok( condition & ...
        exist(outputFileName, 'file') > 0, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% process multiple files
try
    
    name = 'process multiple datasets';
    
    data = cell(1, 3);
    for i = 1:3,
        data{i} = import(physioset.import.matrix, randn(10, 1000));
    end
    
    myCrit = spt.criterion.threshold(spt.feature.tfd, ...
        'MaxCard', 2, 'MinCard', 2);
    
    myNode = bss.new(...
        'Save',             true, ...
        'Parallelize',      false, ...
        'GenerateReport',   false, ...
        'Criterion',        myCrit, ...
        'Reject',           []);
    
    newData = run(myNode, data{:});
    
    ok( all(cellfun(@(x) size(x, 1) == 2, newData)) & ... 
        all(cellfun(@(x) ...
        exist(get_output_filename(myNode, x), 'file') > 0, data)), ...
        name);
    
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% oge
try
    
    name = 'oge';
    
    if has_oge,
        
        warning('off', 'sensors:InvalidLabel');
        eegSensors = sensors.eeg.from_template('egi256', 'PhysDim', 'uV');
        warning('on', 'sensors:InvalidLabel');
        
        eegSensors   = subset(eegSensors, 1:32:256);
        dummySensors = sensors.dummy(2);
        allSensors   = sensors.mixed(eegSensors, dummySensors);
        
        data = cell(1, 3);
        
        importer = physioset.import.matrix(250, 'Sensors', allSensors);
        
        for i = 1:3,
            
            data{i} = import(importer, rand(10, 50000));
            
            set_bad_sample(data{i}, 50:2500);
            set_bad_channel(data{i}, 1:3);
            
        end
        
        myCrit = spt.criterion.threshold(spt.feature.tkurtosis, ...
            'MaxCard', 2, 'MinCard', 2);
        myNode = bss.new('Save', true, 'Reject', [], 'Criterion', myCrit);
        dataFiles = run(myNode, data{:});
        
        pause(5); % give time for OGE to do its magic
        MAX_TRIES = 100;
        tries = 0;
        while tries < MAX_TRIES && ~exist(dataFiles{3}, 'file'),
            pause(5);
            tries = tries + 1;
        end
 
        ok(exist(dataFiles{3}, 'file') > 0, name);
        
    else
        ok(NaN, name, 'OGE is not available');
    end
    
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
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
end

%% Testing summary
status = finalize();