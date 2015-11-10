function [status, MEh] = test1()
% TEST1 - Tests basic node functionality

import mperl.file.spec.*;
import meegpipe.node.erp.*;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import oge.has_oge;
import physioset.event.event;
import physioset.event.class_selector;

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
    erp;
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% constructor with config options
try
    
    name = 'construct bad_epochs node with using a custom config';
    mySel  = class_selector('Type', 'myevent');
    myNode = erp(...
        'EventSelector', mySel, ...
        'Duration',      0.7, ...
        'Offset',        -0.1, ...
        'Baseline',     [-0.1 0]);
    ok(abs(get_config(myNode, 'Duration') - 0.7)<eps, name);
    
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
    myNode = erp('EventSelector', mySel);
    
    run(myNode, data);
    
    feat = get_erp_features(myNode);
    wv = get_erp_waveform(myNode);
    
    ok( ...
        iscell(feat) && ...
        numel(feat) == 1 && ...
        size(feat{1},2) == 4 && ...
        size(wv, 2) == 100, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% multiple channel sets
try
    
    name = 'multiple channel sets';

    data = my_sample_data();
    
    set_bad_sample(data, 1000:5000);
    
    mySel  = class_selector('Type', 'myevent');
    myNode = erp('EventSelector', mySel, 'Channels', {'EEG 1', 'EEG 30'});
    
    run(myNode, data);
    
    feat = get_erp_features(myNode);
    wv = get_erp_waveform(myNode);
    
    ok( ...
        iscell(feat) && ...
        numel(feat) == 2 && ...
        size(feat{1},2) == 4 && ...
        size(wv, 2) == 100, name);
    
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
    myNode = my_sample_node('Save', false, 'OGE', false);
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
    
    myNode = my_sample_node('Save', true);

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
        
        myNode    = my_sample_node('Save', true, 'OGE', true);
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
add_event(data, ev);

end

function myNode = my_sample_node(varargin)

import physioset.event.class_selector;
import meegpipe.node.erp.erp;

mySel  = class_selector('Type', 'myevent');
myNode = erp(...
    'EventSelector', mySel, ...
    'Duration',      0.5, ...
    'Offset',        -0.1, ...
    'Baseline',     [-0.1 0], ...
    'PeakLatRange',  [0.1 0.3], ...
    'AvgWindow',    0.05, ...
    'MinMax',       'min', ...
    'Filter',       filter.ba(ones(1, 10)/10, 1), varargin{:});


end