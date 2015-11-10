function [status, MEh] = test_condor()
% TEST_CONDOR- Tests condor functionality

import mperl.file.spec.*;
import meegpipe.node.*;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import oge.has_condor;

MEh     = [];

initialize(3);

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

%% run bss node via condor
try
    
    name = 'run bss node via condor';
    
    if has_condor,
        
        warning('off', 'sensors:InvalidLabel');
        eegSensors = sensors.eeg.from_template('egi256', 'PhysDim', 'uV');
        warning('on', 'sensors:InvalidLabel');
        
        eegSensors   = subset(eegSensors, 1:32:256);
        dummySensors = sensors.dummy(2);
        allSensors   = sensors.mixed(eegSensors, dummySensors);
        
        data = cell(1, 3);
        
        importer = physioset.import.matrix(250, 'Sensors', allSensors);
        
        for i = 1:3,
            
            data{i} = import(importer, rand(10, 50000));
            
            set_bad_sample(data{i}, 50:2500);
            set_bad_channel(data{i}, 1:3);
            
        end
        
        myNode = bss.new('Save', true, 'Queue', 'condor');
        dataFiles = run(myNode, data{:});
        
        pause(7); % give time for condor to do its magic
        MAX_TRIES = 100;
        tries = 0;
        while tries < MAX_TRIES && ~exist(dataFiles{3}, 'file'),
            pause(5);
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