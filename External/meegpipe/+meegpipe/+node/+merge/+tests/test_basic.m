function [status, MEh] = test_basic()
% test_basic - Tests basic node functionality

import mperl.file.spec.*;
import meegpipe.node.*;
import filter.lpfilt;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import oge.has_oge;
import misc.get_username;
import meegpipe.node.merge.sample_data;

MEh = [];

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
    status = finalize();
    return;
    
end


%% default constructor
try
    
    name = 'default constructor';
    myNode = merge.new; %#ok<NASGU>
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% constructor from config object
try
    
    name = 'constructor from config object';
    
    myCfg  = merge.config('Importer', physioset.import.mff);
    myNode = merge.new(myCfg);
    
    impObj = get_config(myNode, 'Importer');
    ok(...
        isa(impObj{1}, 'physioset.import.mff'), ...
        name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% constructor with config options
try
    
    name = 'constructor with config options';
    
    myNode = merge.new('Importer', physioset.import.mff);
    
    impObj = get_config(myNode, 'Importer');
    ok(...
        isa(impObj{1}, 'physioset.import.mff'), ...
        name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% process sample data
try
    
    name = 'process sample data';
    
    myNode = merge.new('Importer', physioset.import.physioset);
    
    [file, data] = sample_data(3);
    
    mergedData = run(myNode, file);
    
    nbPoints = 0;
    for i = 1:numel(data)
        nbPoints = nbPoints + size(data{i}, 2);
    end
    
    ok(size(mergedData, 2) == nbPoints, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% save node output
try
    
    name = 'save node output';
    
    myNode = merge.new('Importer', physioset.import.physioset, ...
        'Save', true);
    
    file = sample_data(2);
    
    run(myNode, file);
    
    ok(exist(get_output_filename(myNode, file{1}), 'file')>0, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% process multiple files
try
    
    name = 'process multiple merging sets';
    
    data = cell(1, 3);
    file = cell(1, 3);
    
    nbPoints = zeros(1, 3);
    for i = 1:3,
        [file{i}, data{i}] = sample_data(2);
        for j = 1:numel(data{i})
            nbPoints(i) = nbPoints(i) + size(data{i}{j}, 2);
        end
    end
    
    myNode = merge.new('Importer', physioset.import.physioset, ...
        'OGE', false);
    mergedData = run(myNode, file{:});
    
    
    ok(iscell(mergedData) && numel(mergedData) == 3 && ...
        size(mergedData{1},2) == nbPoints(1), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% oge
try
    
    name = 'oge';
    if has_oge,
        
        data = cell(1, 3);
        file = cell(1, 3);
        
        nbPoints = zeros(1, 3);
        for i = 1:3,
            [file{i}, data{i}] = sample_data(2);
            for j = 1:numel(data{i})
                nbPoints(i) = nbPoints(i) + size(data{i}{j}, 2);
            end
        end
        
        myNode = merge.new(...
            'Importer', physioset.import.physioset, ...
            'OGE',      true, ...
            'Save',     true);
        
        mergedDataFiles = run(myNode, file{:});
        
        pause(5); % give time for OGE to do its magic
        MAX_TRIES = 100;
        tries = 0;
        
        while tries < MAX_TRIES && ~exist(mergedDataFiles{3}, 'file'),
            pause(1);
            tries = tries + 1;
        end
        [~, ~] = system(sprintf('qdel -u %s', get_username));
        
        ok(exist(mergedDataFiles{3}, 'file') > 0, name);
        
        
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
    clear data mergedData;
    rmdir(session.instance.Folder, 's');
    session.clear_subsession();
    ok(true, name);
    
catch ME
    ok(ME, name);
end

%% Testing summary
status = finalize();