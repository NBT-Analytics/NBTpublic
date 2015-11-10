function [status, MEh] = test1()
% TEST1 - Tests basic node functionality

import mperl.file.spec.*;
import ecgpuwave.*;
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


%% process sample data using existing VM
try
    
    name   = 'process sample data using existing VM';
    
    tmp = load(catfile(meegpipe.root_path, '+data', 'ecg.mat'), 'ecg');
    ecg = tmp.ecg;
    
    mySensors  = sensors.physiology('Label', 'ECG');
    myImporter = physioset.import.matrix('Sensors', mySensors);
    
    data = import(myImporter, ecg);
    
    myNode = ecg_annotate('VMUrl', '192.87.10.186');
    
    run(myNode, data);
    
    % ensure the imported and original data are identical
    ok(numel(get_event(data))>0, name);
    clear data;
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% multiple experimental conditions (existing VM)
try
    
    name   = 'multiple experimental conditions (existing VM)';
    
    tmp = load(catfile(meegpipe.root_path, '+data', 'ecg.mat'), 'ecg');
    ecg = tmp.ecg;
    
    mySensors  = sensors.physiology('Label', 'ECG');
    myImporter = physioset.import.matrix('Sensors', mySensors);
    
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
    
    myNode = ecg_annotate('VMUrl', '192.87.10.186', ...
        'EventSelector', {selDark, selBlue, selRed});
    
    run(myNode, data);
    
    % ensure the imported and original data are identical
    ok(numel(get_event(data))>0, name);
    clear data;
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% process sample data starting a local VM
try
    
    name   = 'process sample data starting a local VM';
    
    tmp = load(catfile(meegpipe.root_path, '+data', 'ecg.mat'), 'ecg');
    ecg = tmp.ecg;
    
    mySensors  = sensors.physiology('Label', 'ECG');
    myImporter = physioset.import.matrix('Sensors', mySensors);
    
    data = import(myImporter, ecg);
    
    myNode = ecg_annotate;
    
    run(myNode, data);
    
    % ensure the imported and original data are identical
    ok(numel(get_event(data))>0, name);
    clear data;
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% save node output (use existing VM)
try
    
    name   = 'save node output (use existing VM)';
    
    tmp = load(catfile(meegpipe.root_path, '+data', 'ecg.mat'), 'ecg');
    ecg = tmp.ecg;
    
    mySensors  = sensors.physiology('Label', 'ECG');
    myImporter = physioset.import.matrix('Sensors', mySensors);
    
    data = import(myImporter, ecg);
    
    myNode = ecg_annotate('Save', true, 'VMUrl', '192.87.10.186');
    
    run(myNode, data);
    
    ok(exist(get_output_filename(myNode, data), 'file')>0, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% save node output (start new VM)
try
    
    name   = 'save node output (start new VM)';
    
    tmp = load(catfile(meegpipe.root_path, '+data', 'ecg.mat'), 'ecg');
    ecg = tmp.ecg;
    
    mySensors  = sensors.physiology('Label', 'ECG');
    myImporter = physioset.import.matrix('Sensors', mySensors);
    
    data = import(myImporter, ecg);
    
    myNode = ecg_annotate('Save', true);
    
    run(myNode, data);
    
    ok(exist(get_output_filename(myNode, data), 'file')>0, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% process multiple files (use existing VM)
try
    
    name = 'process multiple datasets (use existing VM)';
    
    tmp = load(catfile(meegpipe.root_path, '+data', 'ecg.mat'), 'ecg');
    ecg = tmp.ecg;
    
    mySensors  = sensors.physiology('Label', 'ECG');
    myImporter = physioset.import.matrix('Sensors', mySensors);
    
    data = cell(1, 3);
    for i = 1:3,
        data{i} = import(myImporter, ecg + randn(size(ecg)));
    end
    
    myNode = ecg_annotate('OGE', false, 'VMUrl', '192.87.10.186');
    run(myNode, data{:});
    
    ok(numel(get_event(data{3}))>0, name);
    clear physObj;
    
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
    
    myNode = ecg_annotate('OGE', false);
    run(myNode, data{:});
    
    ok(numel(get_event(data{3}))>0, name);
    clear physObj;
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% oge
try
    
    name = 'Oracle grid engine (use existing VM)';
    
    if has_oge,
        tmp = load(catfile(meegpipe.root_path, '+data', 'ecg.mat'), 'ecg');
        ecg = tmp.ecg;
        
        mySensors  = sensors.physiology('Label', 'ECG');
        myImporter = physioset.import.matrix('Sensors', mySensors);
        
        data = cell(1, 3);
        for i = 1:3,
            data{i} = import(myImporter, ecg + randn(size(ecg)));
        end
        
        myNode = ecg_annotate('OGE', true, 'VMUrl', '192.87.10.186');
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