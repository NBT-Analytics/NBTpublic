function [status, MEh] = test_bad_data()
% TEST1 - Tests demo functionality

import test.simple.*;
import mperl.file.spec.*;
import physioset.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import goo.method_config;

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

%% add_boundary_events
try
    
    name = 'add_boundary_events';
   
    myImporter = physioset.import.matrix('Sensors', sensors.eeg.dummy(5));
    data = import(myImporter, randn(5,10000));
    add_event(data, physioset.event.std.qrs(1:100:5000));
    [data, evIdx] = set_bad_sample(data, [200:300 400:500]);
   
    ev = get_event(data);
    discClass = 'physioset.event.std.discontinuity';
    ok(numel(ev)==52 & numel(evIdx) == 2 & ...
        isa(ev(evIdx(1)), discClass) & ...
        isa(ev(evIdx(2)), discClass), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% add_boundary_events: no duplicate events
try
    
    name = 'add_boundary_events: no duplicate events';
   
    myImporter = physioset.import.matrix('Sensors', sensors.eeg.dummy(5));
    data = import(myImporter, randn(5,10000));
    add_event(data, physioset.event.std.qrs(1:100:5000));
    [data, evIdx] = set_bad_sample(data, [200:300 400:500]);
    
    [data, newEvIdx] = add_boundary_events(data);
    
    ev = get_event(data);
    
    discClass = 'physioset.event.std.discontinuity';
    ok(numel(ev)==52 & numel(evIdx) == 2 & ...
        isa(ev(evIdx(1)), discClass) & ...
        isa(ev(evIdx(2)), discClass) & isempty(newEvIdx), name);
    
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