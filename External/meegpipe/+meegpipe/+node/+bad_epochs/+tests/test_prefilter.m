function [status, MEh] = test_prefilter()
% TEST_PREFILTER - Tests pre-filtering option

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

% Number of tests that should run if everything goes OK
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

%% process sample data with pre-filtering
try
    
    name = 'process sample data with pre-filtering';
    
    data = my_sample_data();
    
    myCrit = bad_epochs.criterion.stat.new(...
        'ChannelStat',  @(x) min(x), ...
        'EpochStat',    @(x) min(x), ...
        'MinCard',      @(x) 0, ...
        'MaxCard',      @(x) Inf, ...
        'Min',          -20, ...
        'Max',          Inf);
    
    myNode = my_sample_node(myCrit, 'GenerateReport', false, ...
        'PreFilter',    filter.median('Order', 5));
    
    run(myNode, data);
    
    ok(~any(is_bad_sample(data)), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% process sample data without pre-filtering
try
    
    name = 'process sample data without pre-filtering';
    
    data = my_sample_data();
    
    myCrit = bad_epochs.criterion.stat.new(...
        'ChannelStat',  @(x) min(x), ...
        'EpochStat',    @(x) min(x), ...
        'MinCard',      @(x) 0, ...
        'MaxCard',      @(x) Inf, ...
        'Min',          -20, ...
        'Max',          Inf);
    
    myNode = my_sample_node(myCrit);
    
    run(myNode, data);
    
    ok(numel(find(is_bad_sample(data))) == 125, name);
    
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
function [data, bad] = my_sample_data()
import physioset.event.event;

X = sin(2*pi*(1/100)*(0:199));
X = rand(10,1)*X;
X = repmat(X, [1 1 50]);
X = X + 0.25*rand(size(X));

X(1, 50, 10) = 20;
X(1, 30, 20) = -30;
bad = [10 20];

sens = sensors.eeg.from_template('egi256');
sens = subset(sens, ceil(linspace(1, nb_sensors(sens), 10)));
data = import(physioset.import.matrix('Sensors', sens), X);

pos = get(get_event(data), 'Sample');
off = ceil(0.1*data.SamplingRate);
ev = event(pos + off, 'Type', 'myevent', 'Duration', data.SamplingRate);
add_event(data, ev);

end


function myNode = my_sample_node(myCrit, varargin)

import physioset.event.class_selector;
import meegpipe.node.bad_epochs.bad_epochs;
import meegpipe.node.bad_epochs.criterion.stat.stat;

mySel  = class_selector('Type', 'myevent');

myNode = bad_epochs(...
    'Criterion',     myCrit, ...
    'Duration',      0.5, ...
    'Offset',        -0.1, ...
    'EventSelector', mySel, ...
    'Save',          true, ...
    varargin{:});


end