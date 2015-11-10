function [status, MEh] = test1()
% TEST1 - Tests basic node functionality

import mperl.file.spec.*;
import meegpipe.node.subset.*;
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

initialize(11);

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
    myNode = subset; %#ok<NASGU>
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% constructor from config object
try
    
    name = 'constructor from config object';

    myCfg  = config('AutoDestroyMemMap', true); 
    myNode = subset(myCfg);
    bool = get_config(myNode, 'AutoDestroyMemMap');
    
    ok(bool, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% constructor with config options
try
    
    name = 'constructor with config options';   
    myNode = subset('AutoDestroyMemMap', true);    
    bool = get_config(myNode, 'AutoDestroyMemMap');   
    ok(bool, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% process sample data
try
    
    name = 'process sample data';
    
    sel1 = pset.selector.sensor_idx(5:8);
    sel2 = pset.selector.sensor_idx(2:3);
    
    myNode1 = subset('DataSelector', sel1);
    myNode2 = subset('DataSelector', sel2);
    myPipe  = pipeline(myNode1, myNode2);
    
    data = import(physioset.import.matrix, randn(10, 1000));

    newData = run(myPipe, data);
    
    ok(size(newData,1) == 2, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% process sample data
try
    
    name = 'process sample data with AutoDestroyMemMap=true';
    
    sel1 = pset.selector.sensor_idx(5:8);
    sel2 = pset.selector.sensor_idx(2:3);
    
    myNode1 = subset('DataSelector', sel1);
    myNode2 = subset('DataSelector', sel2, 'AutoDestroyMemMap', true);
    myPipe  = pipeline(myNode1, myNode2);
    
    data = import(physioset.import.matrix, randn(10, 1000));

    newData = run(myPipe, data);
    
    ok(newData.PointSet.AutoDestroyMemMap & size(newData,1) == 2, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% pipeline with GenerateReport = false
try
    
    name = 'process sample data with GenerateReport = false';
    
    data = import(physioset.import.matrix, randn(10, 1000));
    save(data);
    file = get_hdrfile(data);
    clear data;
    
    myNode1 = meegpipe.node.physioset_import.new('Importer', physioset.import.physioset);
    sel = pset.selector.sensor_idx(2:3);
    myNode2 = subset('DataSelector', sel, ...
        'Save', true);
    myPipe  = pipeline('NodeList', {myNode1, myNode2}, ...
        'GenerateReport', false, 'Save', false);
    
    newData = run(myPipe, file);
    
    ok(size(newData,1) == 2, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% save node output
try
    
    name = 'save node output';
    
    sel = pset.selector.sensor_idx(5:8);
    myNode = subset('DataSelector', sel, 'Save', true);
    
    data = import(physioset.import.matrix, randn(10, 1000));
    
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
    
    data = cell(1, 3);
    for i = 1:3,
        data{i} = import(physioset.import.matrix, randn(10, 1000));
    end
    
    sel = pset.selector.sensor_idx(5:8);
    myNode = subset('DataSelector', sel, 'OGE', false);
    newData = run(myNode, data{:});
    ok(size(newData{1},1) == 4, name);
    
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
            data{i} = import(physioset.import.matrix, randn(10, 1000));
            
        end
        
        sel = pset.selector.sensor_idx(5:8);
        myNode = subset('DataSelector', sel, 'OGE', true, 'Save', true);
        
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