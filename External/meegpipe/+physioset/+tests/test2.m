function [status, MEh] = test2()
% TEST2 - Conversion to/from EEGLAB and Fieldtrip structures

import test.simple.*;
import mperl.file.spec.*;
import physioset.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;

MEh     = [];

initialize(4);

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

%% Continuous dataset to EEGLAB
try
    
    name = 'conversion to EEGLAB (continuous)';
   
    myImporter = physioset.import.matrix('Sensors', sensors.eeg.dummy(5));
    data = import(myImporter, randn(5,10000));
    add_event(data, physioset.event.std.qrs(1:100:5000));
    eeglabStr = eeglab(data);
    
    ok(numel(eeglabStr.event)==50 & ...
        all(size(eeglabStr.data) == [5 10000]), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Epoched dataset to EEGLAB
try
    
    name = 'conversion to EEGLAB (epoched)';
   
    myImporter = physioset.import.matrix('Sensors', sensors.eeg.dummy(5));
    data = import(myImporter, randn(5,10000));
    add_event(data, physioset.event.std.qrs(1:100:5000));
    trialEvs = physioset.event.std.trial_begin(1:100:10000);
    trialEvs = set_duration(trialEvs, 100);
    add_event(data, trialEvs );
    eeglabStr = eeglab(data);
    
    ok(numel(eeglabStr.event)==50 & ...
        all(size(eeglabStr.data) == [5 100 100]), name);
    
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Cleanup
try
    
    name = 'cleanup';
    clear data ans;
    rmdir(session.instance.Folder, 's');
    session.clear_subsession();
    ok(true, name);
    
catch ME
    ok(ME, name);
end

%% Testing summary
status = finalize();

end