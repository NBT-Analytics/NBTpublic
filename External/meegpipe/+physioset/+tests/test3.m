function [status, MEh] = test3()
% TEST3 - Simple unit tests for all physioset methods

import test.simple.*;
import mperl.file.spec.*;
import physioset.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;

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

%% set_bad_channel/is_bad_channel/clear_bad_channel
try
    
    name = 'set_bad_channel/is_bad_channel/clear_bad_channel';
   
    myImporter = physioset.import.matrix('Sensors', sensors.eeg.dummy(7));
    data = import(myImporter, randn(7,10000));
    
    cond1 = ~any(is_bad_channel(data));
    
    set_bad_channel(data, [1 3 5 7]);
    
    cond2 = all(find(is_bad_channel(data)) == [1 3 5 7]);
    
    clear_bad_channel(data, [3 5]);
    
    cond3 = all(find(is_bad_channel(data)) == [1 7]);
    
    clear_bad_channel(data);
    
    cond4 = ~any(is_bad_channel(data));
    
    ok(cond1 & cond2 & cond3 & cond4, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% default method configuration
try
    name = 'default method configuration';
    
    obj = physioset.physioset;
    
    cfg = get_method_config(obj, 'fprintf', 'ParseDisp');
    
    cfgDef = physioset.default_method_config;
    
    cfgDef = get_method_config(cfgDef, 'fprintf', 'ParseDisp');
    
    ok(cfgDef{2} == cfg{2}, name);
 
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
end

%% set/get method configuration
try
    name = 'set/get method configuration';
    
    obj = physioset.physioset;
    
    cfg = get_method_config(obj, 'fprintf', 'ParseDisp');
    
    newVal = ~cfg{2};
    set_method_config(obj, 'fprintf', 'ParseDisp', newVal);
    cfg = get_method_config(obj, 'fprintf', 'ParseDisp');
    
    ok(newVal == cfg{2}, name);
 
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
end

%% fprintf
try
    name ='fprintf';
    obj = physioset.physioset; %#ok<*NASGU>
    evalc('count = fprintf(1, obj);');
    
    ok(count > 300, name); %#ok<NODEF>
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
end

%% modify fprintf config
try
    name ='modify fprintf config';
    obj = physioset.physioset;
    set_method_config(obj, 'fprintf', 'ParseDisp', false);
    count = fprintf(1, obj);
    
    ok(count == 0, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
end

%% set_sensors
try
    name ='set_sensors';
    X = randn(5, 100);
    data = import(physioset.import.matrix, X);
    select(data, [2 1 3 5 4]);
    set_sensors(data, sensors.dummy(5));
    clear_selection(data);
    sensLabels = labels(sensors(data));
    idx = cellfun(@(x) str2double(x), sensLabels);
    ok(all(idx == [2 1 3 5 4]'), name);
    
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