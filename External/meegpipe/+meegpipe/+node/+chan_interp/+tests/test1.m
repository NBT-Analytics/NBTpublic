function [status, MEh] = test1()
% TEST1 - Tests basic node functionality

import mperl.file.spec.*;
import meegpipe.node.chan_interp.*;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import oge.has_oge;

MEh     = [];

initialize(10);

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
    chan_interp; 
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% constructor with config options
try
    
    name = 'construct node that uses 10 NNs';
    obj = chan_interp('NN', 10, 'ClearBadChannels', true);
    ok(...
        get_config(obj, 'NN') == 10 && ...
        get_config(obj, 'ClearBadChannels'), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% ClearBadChannels = true
try
    
    name = 'ClearBadChannels = true';

    data = my_sample_data();
     
    myNode = chan_interp('NN', 2, 'ClearBadChannels', true);    
    
    badIdx = is_bad_channel(data);
    run(myNode, data);    
    
    ok(...
        min(std(data(badIdx, :), [], 2)) > 1e-3 && ...
        ~any(is_bad_channel(data)), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% process HD sample data
try
    
    name = 'process HD sample data';

    data = my_hd_sample_data();
     
    myNode = chan_interp('NN', 5);    
    
    run(myNode, data);    
    
    ok(min(std(data(is_bad_channel(data), :), [], 2)) > 1e-3, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% process sample data
try
    
    name = 'process sample data';

    data = my_sample_data();
     
    myNode = chan_interp('NN', 2);    
    
    run(myNode, data);    
    
    ok(min(std(data(is_bad_channel(data), :), [], 2)) > 1e-3, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% process multiple files
try
    
    name = 'process multiple datasets';
    
    data = cell(1, 2);
    for i = 1:2,
        data{i} = my_sample_data();
    end
     myNode = chan_interp('NN', 2, 'Save', false, 'OGE', false);   
    run(myNode, data{:});
    ok(true, name);    
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% save node output
try
    
    name = 'save node output';
    
    data = my_sample_data();
    
    myNode = chan_interp('NN', 2, 'Save', true);

    outputFileName = get_output_filename(myNode, data);
    run(myNode, data);
    
    ok(exist(outputFileName, 'file')>0, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% oge
try
    
    name = 'oge';
    if has_oge,
        
        name = 'oge';
        
        data = cell(1, 3);
        for i = 1:3,
            data{i} = my_sample_data();
        end
        
        myNode    = chan_interp('NN', 2, 'Save', true, 'OGE', true);
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

end

%% Helper functions
function data = my_sample_data()
import physioset.event.event;

sens = sensors.eeg.from_template('egi256');
sens = subset(sens, ceil(linspace(1, nb_sensors(sens), 10)));
data = import(physioset.import.matrix('Sensors', sens), randn(10, 10000));

data(3, :) = 0;
data(5, :) = 0;

set_bad_channel(data, [3 5]);

end

function data = my_hd_sample_data()
import physioset.event.event;

sens = sensors.eeg.from_template('egi256');
data = import(physioset.import.matrix('Sensors', sens), randn(257, 10000));

data(3, :) = 0;
data(25, :) = 0;
data(100, :) = 0;

set_bad_channel(data, [3 25 100]);

end

