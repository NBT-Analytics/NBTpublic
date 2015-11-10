function [status, MEh] = test1()
% TEST1 - Tests basic node functionality

import mperl.file.spec.*;
import meegpipe.node.copy.*;
import meegpipe.node.physioset_import.physioset_import;
import meegpipe.node.filter.filter;
import meegpipe.node.pipeline.pipeline;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import oge.has_oge;
import misc.get_username;

% number of samples for the simulated signals. Do not use less than 5000 or
% the filters may be too long for the signal
NB_SAMPLES = 10000;

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
    myNode = copy; %#ok<NASGU>
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% constructor from config object
try
    
    name = 'constructor from config object';
    myCfg = config('PreFix', 'myprefix_', 'PostFix', '_mypostfix');
    myNode = copy(myCfg);
    ok(...
        strcmp(get_config(myNode, 'PreFix'), 'myprefix_') && ...
        strcmp(get_config(myNode, 'PostFix'), '_mypostfix'), ...
        name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% constructor with config options
try
    
    name = 'constructor with config options';
    myNode = copy('PreFix', 'myprefix_', 'PostFix', '_mypostfix');
    ok(...
        strcmp(get_config(myNode, 'PreFix'), 'myprefix_') && ...
        strcmp(get_config(myNode, 'PostFix'), '_mypostfix'), ...
        name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% small pipeline (saving output)
try
    
    name = 'small pipeline (saving output)';
    data = import(physioset.import.matrix, randn(2, NB_SAMPLES));
    
    save(data);
    
    myPipe = pipeline('NodeList', ...
        { ...
        physioset_import('Importer', physioset.import.physioset), ...
        copy, ...
        filter('Filter', filter.bpfilt('fp', [5 10]/125)) ...
        }, 'Save', false);
    
    newData = run(myPipe, get_hdrfile(data));
    
    newData(1,:) = 0;
    
    condition1 = all(newData(1,:) < eps) & any(data(1,:)>0.1);
    copyFile = get_datafile(newData);
    condition2 = exist(copyFile, 'file') > 0;
    clear newData; % the processed physioset should be temporary
    condition3 = ~exist(copyFile, 'file');
    ok(condition1 & condition2 & condition3, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% small pipeline
try
    
    name = 'small pipeline';
    data = import(physioset.import.matrix, randn(2, NB_SAMPLES));
    
    save(data);
    
    myPipe = pipeline('NodeList', ...
        { ...
        physioset_import('Importer', physioset.import.physioset), ...
        copy, ...
        filter('Filter', filter.bpfilt('fp', [5 10]/125)) ...
        });
    
    newData = run(myPipe, get_hdrfile(data));
    
    newData(1,:) = 0;
    
    condition1 = all(newData(1,:) < eps) & any(data(1,:)>0.1);
    copyFile = get_datafile(newData);
    condition2 = exist(copyFile, 'file');
    clear newData; % the copy node output should be deleted
    condition3 = ~exist(copyFile, 'file');
    ok(condition1 & condition2 & condition3, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% process sample data
try
    
    name = 'process sample data';
    myNode = copy('PreFix', 'myprefix_', 'PostFix', '_mypostfix', 'Save', true);
    data = import(physioset.import.matrix, randn(10, NB_SAMPLES));
    dataCopy = run(myNode, data);
    
    [~, origFileName] = fileparts(get_datafile(data));
    [~, newFileName]  = fileparts(get_datafile(dataCopy));
    condition1 = ...
        strcmp(['myprefix_' origFileName '_mypostfix'], newFileName) && ...
        all(abs(dataCopy(1:1000) - data(1:1000)) < eps) && ...
        all(abs(dataCopy(:) - data(:)) < eps);
    
    % ensure copy and original are truly independent
    dataCopy(1, 1:1000) = 0;
    condition2 = ...
        all(abs(data(1, 1:1000) - dataCopy(1, 1:1000) - ...
        data(1, 1:1000)) < eps);
    
    ok(condition1 & condition2, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% save node output
try
    
    name = 'save node output';
    myNode = copy('PreFix', 'myprefix_', 'PostFix', '_mypostfix', ...
        'Save', true);
    data = import(physioset.import.matrix, randn(10, 1000));
    dataCopy = run(myNode, data);
    savePath = get_save_dir(myNode);
    [~, fileName, fileExt] = fileparts(get_datafile(dataCopy));
    savedFile = catfile(savePath, [fileName fileExt]);
    
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
    myNode = copy('PreFix', 'myprefix_', 'PostFix', '_mypostfix', ...
        'OGE', false);
    run(myNode, data{:});
    ok(true, name);
    
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% oge
try
    
    name = 'oge';
    if has_oge,
        % create 3 random physioset objects
        data = cell(1, 3);
        for i = 1:3,
            data{i} = import(physioset.import.matrix, randn(2, NB_SAMPLES));
        end
        myNode = copy('PreFix', 'myprefix_', 'PostFix', '_mypostfix', ...
            'OGE', true, 'Save', true);
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