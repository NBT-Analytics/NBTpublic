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
import physioset.event.event;
import physioset.event.class_selector;

MEh     = [];

initialize(5);

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
    ev_features.new;
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% constructor with config options
try
    
    name = 'construct bad_epochs node with using a custom config';
    mySel  = class_selector('Type', 'myevent');
    myNode = ev_features.new(...
        'EventSelector', mySel, ...
        'Features',      'Time');
    ok(strcmp(get_config(myNode, 'Features'), 'Time'), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% process sample data
try
    
    name = 'process sample data';

    data = my_sample_data();
    
    set_bad_sample(data, 1000:5000);
    
    mySel  = class_selector('Type', 'myevent');
    myNode = ev_features.new('EventSelector', mySel, ...
        'Features', {'Sample', 'Time', 'myprop'});
    
    run(myNode, data);
  
    ok(true, name);
    
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

end

%% Helper functions
function data = my_sample_data()
import physioset.event.event;

X = sin(2*pi*(1/100)*(0:199));
X = rand(10,1)*X;
X = repmat(X, [1 1 50]);
X = X + 0.25*randn(size(X));
sens = sensors.eeg.from_template('egi256');
sens = subset(sens, ceil(linspace(1, nb_sensors(sens), 10)));
data = import(physioset.import.matrix('Sensors', sens), X);

pos = get(get_event(data), 'Sample');
off = ceil(0.1*data.SamplingRate);
ev = event(pos + off, 'Type', 'myevent', 'Duration', 100);

for i = 1:numel(ev)
    ev(i) = set_meta(ev(i), 'myprop', i);
end

add_event(data, ev);

end

