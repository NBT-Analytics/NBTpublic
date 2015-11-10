function [status, MEh] = test1()
% TEST1 - Tests basic node functionality

import mperl.file.spec.*;
import meegpipe.node.*;
import meegpipe.node.pipeline.pipeline;
import filter.lpfilt;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import oge.has_oge;
import misc.get_username;
import physioset.event.std.split_begin;

MEh = [];

initialize(10);

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
    myNode = split.new; %#ok<NASGU>
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% constructor from config object
try
    
    name = 'constructor from config object';
    
    sel = physioset.event.latency_selector(1000, [1 1000]);
    myCfg  = split.config('EventSelector', sel);
    myNode = split.new(myCfg);
    
    sel2 = get_config(myNode, 'EventSelector');
    
    ok(...
        isa(sel2, 'physioset.event.latency_selector'), ...
        name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% constructor with config options
try
    
    name = 'constructor with config options';
    
    sel = physioset.event.latency_selector(1000, [1 1000]);
    myNode = split.new('EventSelector', sel);
    
    sel2 = get_config(myNode, 'EventSelector');
    
    ok(...
        isa(sel2, 'physioset.event.latency_selector'), ...
        name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% process sample data
try
    
    name = 'process sample data';
    
    % Create a test dataset
    data = import(physioset.import.matrix, randn(10, 1000));
    evArray = split_begin(1:100:900, 'Duration', 100);
    add_event(data, evArray);
    
    myNode = split.new;    

    [~, newData] = run(myNode, data);
    
    ok(iscell(newData) & ...
        numel(newData) == 9 & ...
        size(newData{1},2) == 100, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Non-default naming policy
try
    
    name = 'non-default naming policy';
    
    % Create a test dataset
    data = import(physioset.import.matrix, randn(10, 1000));
    evArray = split_begin(1:100:900, 'Duration', 100);
    add_event(data, evArray);
    
    myNode = split.new('SplitNamingPolicy', ...
        @(obj, ev, i) [get(ev, 'Type') num2str(i)]);    

    [~, newData] = run(myNode, data);
    
    ok(iscell(newData) & ...
        numel(newData) == 9 & ...
        size(newData{1},2) == 100, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% save node output
try
    
    name = 'save node output';
        
    % Create a test dataset
    data = import(physioset.import.matrix, randn(10, 1000));
    evArray = split_begin(1:100:900, 'Duration', 100);
    add_event(data, evArray);
    
    myNode = split.new('Save', true);      
   
    [~, newData] = run(myNode, data);
    
    savedFiles = cell(size(newData));
    
    for i = 1:numel(newData)
        savedFiles{i} = get_datafile(newData{i});
    end
    
    clear newData;
     
    ok(exist(savedFiles{1}, 'file')>0, name);
    
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
        evArray = split_begin(1:100:900, 'Duration', 100);
        add_event(data{i}, evArray);
    end
    
    myNode = split.new('OGE', false);      
    [~, newData] = run(myNode, data{:});
    ok(numel(newData) == 3 & ...
        numel(newData{1}) == 9 & ...
        exist(get_datafile(newData{1}{1}), 'file') > 0, name);
    
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
            evArray = split_begin(1:100:900, 'Duration', 100);
            add_event(data{i}, evArray);
        end
        
        myNode = split.new('OGE', true);      
        
        run(myNode, data{:});
        pause(5); % give time for OGE to do its magic
        MAX_TRIES = 100;
        tries = 0;
        
        baseDir = get_full_dir(myNode, data{3});
        outputFile = get_datafile(data{3});
        [~, fName]  = fileparts(outputFile); 
        outputFile = catfile(baseDir, [fName '_split1.pset']);
        while tries < MAX_TRIES && ~exist(outputFile, 'file'),
            pause(1);
            tries = tries + 1;
        end
        
        [~, ~] = system(sprintf('qdel -u %s', get_username));
        
        ok(exist(outputFile, 'file') > 0, name);
        
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