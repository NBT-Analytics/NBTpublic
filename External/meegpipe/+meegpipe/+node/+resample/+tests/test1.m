function [status, MEh] = test1()
% TEST1 - Tests basic node functionality

import mperl.file.spec.*;
import meegpipe.node.resample.*;
import meegpipe.node.pipeline.pipeline;
import filter.lpfilt;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import oge.has_oge;
import misc.get_username;


MEh     = [];

% Number of samples for the simulated datasets
% Do not use less than 10000 or the filters will be too long
NB_SAMPLES = 10000;

initialize(13);

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
    myNode = resample; %#ok<NASGU>
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% constructor from config object
try
    
    name = 'constructor from config object';
    
    myCfg  = config('UpsampleBy', 10, 'DownsampleBy', 20);
    myNode = resample(myCfg);
    
    ok(...
        get_config(myNode, 'UpsampleBy') == 10 && ...
        get_config(myNode, 'DownsampleBy') == 20, ...
        name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% constructor with config options
try
    
    name = 'constructor with config options';
    
    myNode = resample('UpsampleBy', 10, 'DownsampleBy', 20);
    
    ok(...
        get_config(myNode, 'UpsampleBy') == 10 && ...
        get_config(myNode, 'DownsampleBy') == 20, ...
        name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Antialiasing=false
try
    
    name = 'Antialiasing=false';
    
    myNode1 = resample('UpsampleBy', 2, 'Antialiasing', false);
    myNode2 = resample('DownsampleBy', 2, 'Antialiasing', false);
    myPipe  = pipeline(myNode1, myNode2);
    
    data = import(physioset.import.matrix, randn(10, NB_SAMPLES));
    data = filter(lpfilt('fc', 0.1), data);
    
    newData = run(myPipe, data);
    
    ok(max(abs(newData(:)-data(:))) < .001, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% process sample data
try
    
    name = 'process sample data';
    
    myNode1 = resample('UpsampleBy', 2);
    myNode2 = resample('DownsampleBy', 2);
    myPipe  = pipeline(myNode1, myNode2);
    
    data = import(physioset.import.matrix, randn(10, NB_SAMPLES));
    data = filter(lpfilt('fc', 0.1), data);
    
    newData = run(myPipe, data);
    
    ok(max(abs(newData(:)-data(:))) < .1, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% process sample data with AutoDestroyMemMap
try
    
    name = 'process sample data with AutoDestroyMemMap';
    
    myNode1 = resample('UpsampleBy', 2);
    myNode2 = resample('DownsampleBy', 2, 'AutoDestroyMemMap', true);
    myPipe  = pipeline(myNode1, myNode2);
    
    data = import(physioset.import.matrix, randn(10, NB_SAMPLES));
    data = filter(lpfilt('fc', 0.1), data);
    
    newData = run(myPipe, data);
    
    ok(newData.PointSet.AutoDestroyMemMap & ...
        max(abs(newData(:)-data(:))) < .1, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% process sample data using outRate
try
    
    name = 'process sample data specifying outRate';
    
    myNode1 = resample('OutputRate', 125);
    myNode2 = resample('OutputRate', 250);
    myPipe  = pipeline(myNode1, myNode2);
    
    importer = physioset.import.matrix('SamplingRate', 250);
    data = import(importer, randn(10, NB_SAMPLES));
    data = filter(lpfilt('fc', 0.1), data);
    
    newData = run(myPipe, data);
    
    ok(max(abs(newData(:)-data(:))) < .1, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end
%% check selections
try
    
    name = 'check selections';
    
    dataSel = pset.selector.good_data;
    myNode1 = resample('UpsampleBy', 2, 'DataSelector', dataSel);
    myNode2 = resample('DownsampleBy', 2);
    myPipe  = pipeline(myNode1, myNode2);
    
    data = import(physioset.import.matrix, randn(10, NB_SAMPLES));
    data = filter(lpfilt('fc', 0.1), data);
    
    set_bad_channel(data, 2:3);
    set_bad_sample(data, 101:200);
    
    newData = run(myPipe, data);
    
    select(dataSel, data);
    ok(all(size(newData) == [8 9900]) & ...
        max(abs(newData(:) - data(:))) < .1, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% save node output
try
    
    name = 'save node output';
    myNode = resample('UpsampleBy', 2, 'Save', true);
    
    data = import(physioset.import.matrix, randn(10, NB_SAMPLES));
    
    savedFile = get_output_filename(myNode, data);
    
    run(myNode, data);
    
    ok(exist(savedFile, 'file')>0, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% process multiple files
try
    
    name = 'process multiple datasets';
    % create 3 random physioset objects
    data = cell(1, 3);
    for i = 1:3,
        data{i} = import(physioset.import.matrix, randn(10, NB_SAMPLES));
    end
    myNode = resample('DownsampleBy', 2, 'OGE', false);
    newData = run(myNode, data{:});
    ok(size(newData{1},2) == 5000, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% oge
try
    
    name = 'oge';
    if has_oge,
        
        data = cell(1, 3);
        for i = 1:3,
            data{i} = import(physioset.import.matrix, randn(10, NB_SAMPLES));
            
        end
        myNode    = resample('DownsampleBy', 2, 'OGE', true, 'Save', true);
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
    clear data dataCopy ans myCfg myNode;
    rmdir(session.instance.Folder, 's');
    session.clear_subsession();
    ok(true, name);
    
catch ME
    ok(ME, name);
end

%% Testing summary
status = finalize();