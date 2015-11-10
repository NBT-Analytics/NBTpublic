function [status, MEh] = test1()
% TEST1 - Tests basic functionality of class pipeline

import mperl.file.spec.*;
import meegpipe.node.pipeline.*;
import meegpipe.node.copy.copy;
import meegpipe.node.center.center;
import meegpipe.node.physioset_import.physioset_import;
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
    myNode = pipeline; %#ok<NASGU>
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% constructor with config options
try
    
    name = 'constructor with config options';
    myNode = pipeline(physioset_import, copy);
    retrieved = get_config(myNode, 'NodeList');
    
    ok(...
        isa(retrieved{1}, 'meegpipe.node.physioset_import.physioset_import') && ...
        isa(retrieved{2}, 'meegpipe.node.copy.copy'), ...
        name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% process sample data
try
    
    name = 'process sample data';
    myNode = pipeline(physioset_import, copy);
    
    X      = randn(10, 1000);
    data   = run(myNode, X);
    
    ok(max(abs(X(:)-data(:))) < 1e-3, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% save node output
try
    
    name = 'save node output';
    
    myNode = pipeline(physioset_import('Save', true), copy, 'Save', true);  
    
    X = randn(10, 1000);
    dataCopy = run(myNode, X);    
  
    savedFile = get_datafile(dataCopy);
    clear X dataCopy;
    
    ok(exist(savedFile, 'file') > 0, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% process multiple files
try
    
    name = 'process multiple datasets';
    
    data = cell(1, 2);
    for i = 1:2,
        data{i} = randn(10, 1000);
    end
    
    myNode = pipeline(physioset_import, copy, 'OGE', false);
    dataCopy = run(myNode, data{:});
    
    ok(max(abs(data{1}(:)-dataCopy{1}(:))) < 1e-3 && ...
        max(abs(data{2}(:)-dataCopy{2}(:))) < 1e-3, name);    
    
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
            data{i} = randn(10, 1000);           
        end
        
        myNode = pipeline(physioset_import, copy, center, ...
            'OGE', true, 'Queue', 'short.q');
        dataFiles = run(myNode, data{:});
        
        pause(5); % give time for OGE to do its magic
        MAX_TRIES = 100;
        tries = 0;
        while tries < MAX_TRIES && ~exist(dataFiles{3}, 'file'),
            pause(1);
            tries = tries + 1;
        end
        
        [~, ~] = system(sprintf('qdel -u %s', get_username));
        
        ok(true, name);
        
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
    
    pause(5); % Some time for the jobs to be killed
    clear data dataCopy ans myCfg myNode;
    rmdir(session.instance.Folder, 's');
    session.clear_subsession();
    ok(true, name);
    
catch ME
    ok(ME, name);
end

%% Testing summary
status = finalize();