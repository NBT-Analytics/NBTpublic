function [status, MEh] = test1()
% TEST1 - Tests basic node functionality

import mperl.file.spec.*;
import meegpipe.node.physioset_import.*;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import oge.has_oge;
import misc.get_username;

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
    status = finalize();
    return;
    
end


%% default constructor
try
    
    name = 'constructor';
    myNode = physioset_import; %#ok<NASGU>
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% constructor from config object
try
    
    name = 'constructor from config object';
    myCfg = config('Importer', physioset.import.matrix);
    myNode = physioset_import(myCfg);
    ok(...
        isa(get_config(myNode, 'Importer'), 'physioset.import.matrix'), ...
        name ...
        );
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% constructor with config options
try
    
    name = 'constructor with config options';
    myNode = physioset_import('Importer', physioset.import.matrix);
    ok(...
        isa(get_config(myNode, 'Importer'), 'physioset.import.matrix'), ...
        name ...
        );
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% process sample data
try
    
    name   = 'process sample data';
    myNode = physioset_import('Importer', physioset.import.matrix);
    
    X      = randn(10, 1000);
    data   = run(myNode, X);
    
    % ensure the imported and original data are identical 
    ok(max(abs(X(:) - data(:))) < 1e-3, name);
    clear data;
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% save node output
try
    
    name = 'save node output';
    myNode = physioset_import('Importer', physioset.import.matrix, 'Save', true);
    X      = randn(10, 1000);
    run(myNode, X);
    
    ok(exist(get_output_filename(myNode, X), 'file')>0, name);
    
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
        data{i} = randn(10, 1000);
    end
    myNode = physioset_import('Importer', physioset.import.matrix, 'OGE', false);
    physObj = run(myNode, data{:});
    ok(max(abs(data{1}(:) - physObj{1}(:))) < 1e-3, name);
    clear physObj;
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% oge
try
    
    name = 'Oracle grid engine';
    
    if has_oge,
        % create 3 random physioset objects
        data = cell(1, 3);
        for i = 1:3,
            data{i} = randn(10, 1000);
           
        end
        
        % this node will run using OGE
        myNode = physioset_import(...
            'Importer', physioset.import.matrix, ...
            'OGE',      true, ...
            'Save',     true);
        
        % this should submit jobs to OGE
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
    clear data dataCopy;
    rmdir(session.instance.Folder, 's');
    session.clear_subsession();
    ok(true, name);
    
catch ME
    ok(ME, name);
end

%% Testing summary
status = finalize();