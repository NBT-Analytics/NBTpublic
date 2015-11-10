function [status, MEh] = test_basic()
% test_basic - Tests basic node functionality

import mperl.file.spec.*;
import meegpipe.node.*;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import oge.has_oge;
import misc.get_username;

MEh     = [];

initialize(7);

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
    myNode = physioset_export.new; %#ok<NASGU>
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% constructor from config object
try
    
    name = 'constructor from config object';
    myCfg = physioset_export.config('Exporter', physioset.export.eeglab);
    myNode = physioset_export.new(myCfg);
    ok(...
        isa(get_config(myNode, 'Exporter'), 'physioset.export.eeglab'), ...
        name ...
        );
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% constructor with config options
try
    
    name = 'constructor with config options';
    myNode = physioset_export.new('Exporter', physioset.export.eeglab);
    ok(...
        isa(get_config(myNode, 'Exporter'), 'physioset.export.eeglab'), ...
        name ...
        );
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% process sample data
try
    
    name   = 'process sample data';
    myNode = physioset_export.new('Exporter',  physioset.export.eeglab);
    
    X      = randn(10, 1000);
    data   = import(physioset.import.matrix, X);
    
    [~, fName]   = run(myNode, data);
    
    % ensure the imported and original data are identical 
    ok(exist(fName, 'file') > 0, name);

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
        data{i} = import(physioset.import.matrix, randn(10, 1000));
    end
    myNode = physioset_export.new(...
        'Exporter', physioset.export.eeglab, ...
        'OGE',      false);
    [~, fileNames] = run(myNode, data{:});
    ok(all(cellfun(@(x) exist(x, 'file') > 0, fileNames)), name);
    clear physObj;
    
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