function [status, MEh] = test1()
% TEST1 - Tests basic node functionality

import mperl.file.spec.*;
import meegpipe.node.qrs_detect.qrs_detect;
import meegpipe.node.ecg_annotate.*;
import meegpipe.node.pipeline.pipeline;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import oge.has_oge;
import misc.get_username;
import io.edf.write;
import physioset.event.event;
import physioset.event.class_selector;

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
    ecg_annotate;
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% constructor from config object
try
    
    name = 'constructor from config object';
    myCfg = config;
    ecg_annotate(myCfg);
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% process sample data
try
    
    name   = 'process sample data';
    
    tmp = load(catfile(meegpipe.root_path, '+data', 'ecg.mat'), 'ecg');
    ecg = tmp.ecg;
    
    mySensors  = sensors.physiology('Label', 'ECG');
    myImporter = physioset.import.matrix('Sensors', mySensors, ...
        'SamplingRate', 256);
    
    data = import(myImporter, ecg);
    
    myNode1 = qrs_detect;
    myNode2 = ecg_annotate;
    myNode = pipeline('NodeList', {myNode1, myNode2});
    
    featuresFile = catfile(get_full_dir(myNode, data), ...
        ['node-02-' get_name(myNode2)], 'features.txt');
    
    run(myNode, data);
    
    condition = check_features_file(featuresFile, 13, 1);
    
    evs = get_event(data);
    evSel = class_selector('Type', 'N');
    condition = condition && numel(evs) > 0 && ...
        numel(select(evSel, evs)) == 241;
    
    ok(condition, name);
    clear data;
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% multiple experimental conditions
try
    
    name   = 'multiple experimental conditions';
    
    tmp = load(catfile(meegpipe.root_path, '+data', 'ecg.mat'), 'ecg');
    ecg = tmp.ecg;
    
    mySensors  = sensors.physiology('Label', 'ECG');
    myImporter = physioset.import.matrix('Sensors', mySensors, ...
        'SamplingRate', 256);
    
    % Add three experimental conditions
    ev = event(1:1000:3001);
    ev(1) = set(ev(1), 'Type', 'dark-pre', 'Duration', 60000);
    ev(2) = set(ev(2), 'Type', 'red', 'Duration', 60000);
    ev(3) = set(ev(3), 'Type', 'dark', 'Duration', 60000);
    ev(4) = set(ev(4), 'Type', 'blue', 'Duration', 60000);
    
    data = import(myImporter, ecg);
    
    add_event(data, ev);
    
    % The event selectors
    selDark = class_selector('Type', 'dark', 'Name', 'dark');
    selBlue = class_selector('Type', '^blue$', 'Name', 'blue');
    selRed  = class_selector('Type', '^red$', 'Name', 'red');
    
    myNode1 = qrs_detect;
    myNode2 = ecg_annotate('EventSelector', {selDark, selBlue, selRed});
    myPipe = pipeline('NodeList', {myNode1,myNode2});
    
    featuresFile = catfile(get_full_dir(myPipe, data), ...
        ['node-02-' get_name(myNode2)], 'features.txt');
    run(myPipe, data);
    condition = check_features_file(featuresFile, 14, 3);
    
    evs = get_event(data);
    evSel = class_selector('Type', 'N');
    condition = condition && numel(evs) > 0 && ...
        numel(select(evSel, evs)) == 241;
    
    ok(condition, name);
    clear data;
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end



%% process multiple files
try
    
    name = 'process multiple datasets';
    
    tmp = load(catfile(meegpipe.root_path, '+data', 'ecg.mat'), 'ecg');
    ecg = tmp.ecg;
    
    mySensors  = sensors.physiology('Label', 'ECG');
    myImporter = physioset.import.matrix('Sensors', mySensors, ...
        'SamplingRate', 256);
    
    data = cell(1, 3);
    for i = 1:3,
        data{i} = import(myImporter, ecg + randn(size(ecg)));
    end
    
    myNode1 = qrs_detect;
    myNode2 = ecg_annotate;
    myPipe = pipeline('NodeList', {myNode1,myNode2}, 'OGE', false);
    
    run(myPipe, data{:});
    
    ok(numel(get_event(data{3}))>0, name);
    clear physObj;
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% oge
try
    
    name = 'Oracle grid engine';
    
    if has_oge,
        tmp = load(catfile(meegpipe.root_path, '+data', 'ecg.mat'), 'ecg');
        ecg = tmp.ecg;
        
        mySensors  = sensors.physiology('Label', 'ECG');
        myImporter = physioset.import.matrix('Sensors', mySensors, ...
            'SamplingRate', 256);
        
        data = cell(1, 3);
        for i = 1:3,
            data{i} = import(myImporter, ecg + randn(size(ecg)));
        end
        
        myNode1 = qrs_detect;
        myNode2 = ecg_annotate('OGE', true, 'Save', true);
        myPipe = pipeline('NodeList', {myNode1,myNode2});
        dataFiles = run(myPipe, data{:});
        
        pause(5); % give time for OGE to do its magic
        MAX_TRIES = 100;
        tries = 0;
        while tries < MAX_TRIES && ~exist(dataFiles{3}, 'file'),
            pause(1);
            tries = tries + 1;
        end
        [~, ~] = system(sprintf('qdel -u %s', get_username));
        
        featuresFile = catfile(get_full_dir(myPipe, data{1}), ...
            ['node-02-' get_name(myNode2)], 'features.txt');
        
        ok(exist(featuresFile, 'file') > 0, name);
        
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
    % just in case
    [~, ~] = system(sprintf('qdel -u %s', get_username));
    clear data dataCopy myNode;
    rmdir(session.instance.Folder, 's');
    session.clear_subsession();
    ok(true, name);
    
catch ME
    ok(ME, name);
end

%% Testing summary
status = finalize();

end



function condition = check_features_file(featuresFile, nbCols, nbRows)

import safefid.safefid;
import mperl.split;

condition = exist(featuresFile, 'file') > 0;

if condition,
    fid = safefid.fopen(featuresFile, 'r');
    hdr = fgetl(fid);
    condition = condition && numel(split(',', hdr)) == nbCols;
    lineCounter = 0;
    while condition
        line = fgetl(fid);
        if ~ischar(line), break; end
        lineCounter = lineCounter + 1;
    end
    condition = condition && lineCounter == nbRows;
end

end