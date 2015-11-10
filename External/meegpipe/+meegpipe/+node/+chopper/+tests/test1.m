function [status, MEh] = test1()
% TEST1 - Tests basic node functionality

import mperl.file.spec.*;
import meegpipe.node.chopper.*;
import chopper.ged;
import physioset.event.std.*;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import oge.has_oge;

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
    chopper;
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% constructor with config options
try
    
    name = 'construct node with config options';
    myNode = chopper('Event', epoch_begin);
    ok(isa(get_config(myNode, 'Event'), 'physioset.event.std.epoch_begin'), ...
        name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% process sample data
try
    
    name = 'process sample data';
    
    % random data with sinusolidal trend
    X = randn(10,1000);
    X = X + .25*repmat(sin(2*pi*(1/300)*(1:1000)), 10, 1);
    
    X(:,300:500) = rand(10)*X(:,300:500);
    X(:,700:800) = rand(10)*X(:,700:800);
    
    data = import(physioset.import.matrix, X);
    
    myNode = chopper('Algorithm', ged('MinChunkLength', 0));
    run(myNode, data);
    
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% save node output
try
    
    name = 'save node output';
    
    % random data with sinusolidal trend
    X = randn(10,1000);
    X = X + .25*repmat(sin(2*pi*(1/300)*(1:1000)), 10, 1);
    
    X(:,300:500) = rand(10)*X(:,300:500);
    X(:,700:800) = rand(10)*X(:,700:800);
    
    data = import(physioset.import.matrix, X);
    
    myNode = chopper('Algorithm', ged('MinChunkLength', 0), 'Save', true);
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
    
    data = cell(1, 3);
    for i = 1:3,
        X = randn(10,1000);
        X = X + .25*repmat(sin(2*pi*(1/300)*(1:1000)), 10, 1);
        
        X(:,300:500) = rand(10)*X(:,300:500);
        X(:,700:800) = rand(10)*X(:,700:800);
        data{i} = import(physioset.import.matrix, X);
    end
    
    myNode = chopper('Algorithm', ged('MinChunkLength', 0), 'Save', true);
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
        
        name = 'process multiple datasets';
        
        data = cell(1, 3);
        for i = 1:3,
            X = randn(10,1000);
            X = X + .25*repmat(sin(2*pi*(1/300)*(1:1000)), 10, 1);
            
            X(:,300:500) = rand(10)*X(:,300:500);
            X(:,700:800) = rand(10)*X(:,700:800);
            data{i} = import(physioset.import.matrix, X);
        end
        
        myNode = chopper('Algorithm', ged('MinChunkLength', 0), 'Save', true);
      
        dataFiles = run(myNode, data{:});
        
        pause(5); % give time for OGE to do its magic
        MAX_TRIES = 100;
        tries = 0;
        while tries < MAX_TRIES && ~exist(dataFiles{3}, 'file'),
            pause(1);
            tries = tries + 1;
        end
        
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
    clear data dataCopy;
    rmdir(session.instance.Folder, 's');
    session.clear_subsession();
    ok(true, name);
    
catch ME
    ok(ME, name);
end

%% Testing summary
status = finalize();