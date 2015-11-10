function [status, MEh] = test1()
% TEST1 - Tests basic node functionality

import mperl.file.spec.*;
import meegpipe.node.bad_epochs.*;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import oge.has_oge;
import physioset.event.event;
import physioset.event.class_selector;

MEh     = [];

% Number of tests that should run if everything goes OK
initialize(15);


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
    bad_epochs;
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% constructor with config options
try
    
    name = 'construct bad_epochs node with using a custom config';
    mySel  = class_selector('Type', 'myevent');
    
    crit = criterion.stat.stat(...
        'ChannelStat',  @(x) sum(x), ...
        'EpochStat',    @(x) sum(x.^2));
    
    myNode = bad_epochs(...
        'Criterion',     crit, ...
        'EventSelector', mySel, ...
        'Save',          true);
    
    crit = get_config(myNode, 'Criterion');
    chanStat = get_config(crit, 'ChannelStat');
    epochStat = get_config(crit, 'EpochStat');
    ok(chanStat(10) == 10 && epochStat(10) == 100, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% process sample data with many channels
try
    
    name = 'process sample data with many channels';
    
    data = my_sample_data(255);
    
    myNode = my_sample_node();
    
    set_bad_sample(data, 101:300);
    
    run(myNode, data);
    
    ok(numel(find(is_bad_sample(data))) == 250+200, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% process sample data with bad samples
try
    
    name = 'process sample data with bad samples';
    
    data = my_sample_data();
    
    myNode = my_sample_node();
    
    set_bad_sample(data, 101:300);
    
    run(myNode, data);
    
    ok(numel(find(is_bad_sample(data))) == 250+200, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% process sample data
try
    
    name = 'process sample data';
    
    data = my_sample_data();
    
    myNode = my_sample_node();
    
    run(myNode, data);
    
    ok(numel(find(is_bad_sample(data))) == 250, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% process sample data (DeleteEvents=true)
try
    
    name = 'process sample data (DeleteEvents=true)';
    
    data = my_sample_data();
    
    otherEv = event(100, 'Type', 'othertype');
    add_event(data, otherEv);
    
    myNode = my_sample_node('DeleteEvents', true);
    
    run(myNode, data);
    
    ev = get_event(data);
    ok(...
        numel(ev) == 53 && numel(unique(ev)) == 3 && ...
        numel(find(is_bad_sample(data))) == 250, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% sliding_window
try
    
    name = 'sliding_window';
    
    data = my_sample_data();
    
    myCrit = meegpipe.node.bad_epochs.criterion.stat.new(...
        'ChannelStat', @(x) max(abs(x)), ...
        'EpochStat',   @(x) max(x), ...
        'Max',         5);
    
    myNode = sliding_window([], [], 'Criterion', myCrit);
    
    run(myNode, data);
    
    select(pset.selector.good_data, data);
    ok(max(data(1,:)) < 5 && min(data(1,:)) > -5, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% rejecting only 1 epoch
try
    
    name = 'rejecting only 1 epoch';
    
    data = my_sample_data();
    
    myCrit = meegpipe.node.bad_epochs.criterion.stat.new(...
        'ChannelStat',  @(x) max(x), ...
        'EpochStat',    @(chanMax) max(chanMax), ...
        'Max',          15 ...
        );
    
    myNode = sliding_window(1, 1, 'Criterion', myCrit);
    
    run(myNode, data);
    
    % The sliding_window creates epochs of duration 1s
    ok(numel(find(is_bad_sample(data))) == data.SamplingRate, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% sliding_window with Min threshold
try
    
    name = 'sliding_window with Min threshold';
    
    data = my_sample_data();
    
    myCrit = meegpipe.node.bad_epochs.criterion.stat.new(...
        'ChannelStat',  @(x) min(x), ...
        'EpochStat',    @(x) min(x), ...
        'Min',          -1 ...
        );
    
    myNode = sliding_window(0.1, 0.1, ...
        'Criterion', myCrit, 'GenerateReport', false);
    
    run(myNode, data);
    
    select(pset.selector.good_data, data);
    ok(min(data(1,:)) > -1, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% minmax
try
    
    name = 'minmax';
    
    data = my_sample_data();
    
    mySel  = class_selector('Type', 'myevent');
    myNode = minmax(-10, 10, 'EventSelector', mySel);
    
    run(myNode, data);
    
    ok(numel(find(is_bad_sample(data))) == 900, name);
    
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
    
    % Must get output file name before running the node!
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
function [data, bad] = my_sample_data(nbSensors)
import physioset.event.event;

if nargin < 1, nbSensors = 10; end

X = sin(2*pi*(1/100)*(0:199));
X = rand(nbSensors,1)*X;
X = repmat(X, [1 1 50]);
X = X + 0.25*rand(size(X));

X(1, 50, 10) = 20;
X(1, 30, 20) = -30;
bad = [10 20];

sens = sensors.eeg.from_template('egi256');
sens = subset(sens, ceil(linspace(1, nb_sensors(sens), nbSensors)));
data = import(physioset.import.matrix('Sensors', sens), X);

pos = get(get_event(data), 'Sample');
off = ceil(0.1*data.SamplingRate);
ev = event(pos + off, 'Type', 'myevent', 'Duration', data.SamplingRate);
add_event(data, ev);

end

function myNode = my_sample_node(varargin)

import physioset.event.class_selector;
import meegpipe.node.bad_epochs.bad_epochs;
import meegpipe.node.bad_epochs.criterion.stat.stat;

mySel  = class_selector('Type', 'myevent');
crit   = stat(...
    'ChannelStat',  @(x) max(abs(x)), ...
    'EpochStat',    @(x) max(x), ...
    'Max',           15);


myNode = bad_epochs(...
    'Criterion',     crit, ...
    'Duration',      0.5, ...
    'Offset',        -0.1, ...
    'EventSelector', mySel, ...
    'Save',          true, ...
    varargin{:});


end