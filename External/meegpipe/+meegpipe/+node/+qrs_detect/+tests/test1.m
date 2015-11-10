function [status, MEh] = test1()
% TEST1 - Tests basic node functionality

import mperl.file.spec.*;
import meegpipe.node.qrs_detect.*;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import oge.has_oge;
import misc.get_username;

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
    qrs_detect; 
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% constructor with config options
try
    
    name = 'constructor with config options';    
    myNode = qrs_detect('Plotter', []);
    plotterProp = get_config(myNode, 'Plotter');    
    ok(isempty(plotterProp), name);
    
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
    myImporter = physioset.import.matrix('Sensors', mySensors);
    
    data = import(myImporter, ecg);
    
    myNode = qrs_detect;
    
    run(myNode, data);
    
    % ensure the imported and original data are identical
    ok(numel(get_event(data))>0, name);
    clear data;
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% save node output
try
    
    name   = 'save node output';
    
    tmp = load(catfile(meegpipe.root_path, '+data', 'ecg.mat'), 'ecg');
    ecg = tmp.ecg;
    
    mySensors  = sensors.physiology('Label', 'ECG');
    myImporter = physioset.import.matrix('Sensors', mySensors);
    
    data = import(myImporter, ecg);
    
    myNode = qrs_detect('Save', true);
    
    outputFileName = get_output_filename(myNode, data);
    run(myNode, data);
    
    ok(exist(outputFileName, 'file')>0, name);
    
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
    myImporter = physioset.import.matrix('Sensors', mySensors);
    
    data = cell(1, 3);
    for i = 1:3,
        data{i} = import(myImporter, ecg + randn(size(ecg)));
    end
    
    myNode = qrs_detect('OGE', false);
    run(myNode, data{:});
    
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
        myImporter = physioset.import.matrix('Sensors', mySensors);
        
        data = cell(1, 3);
        for i = 1:3,
            data{i} = import(myImporter, ecg + randn(size(ecg)));
        end
        
        myNode = qrs_detect('OGE', true, 'Save', true);
        dataFiles = run(myNode, data{:});
        
        pause(5); % give time for OGE to do its magic
        MAX_TRIES = 100;
        tries = 0;
        while tries < MAX_TRIES && ~exist(dataFiles{3}, 'file'),
            pause(1);
            tries = tries + 1;
        end
        [~, ~] = system(sprintf('qdel -u %s', get_username));
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