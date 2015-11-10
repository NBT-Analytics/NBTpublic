function [status, MEh] = test_data_selector() 
% TEST_DATA_SELECTOR - Tests event-based data selection

import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import misc.get_username;

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

%% select correlative epochs for processing
try
    
    name = 'select correlative epochs for processing';
    
    evGen = physioset.event.periodic_generator('Period', 1, 'Duration', 1);
    data = import(physioset.import.matrix, zeros(2, 1000));
    data(1,:) = 1:1000;
    
    myNode1 = meegpipe.node.ev_gen.new('EventGenerator', evGen);
    
    myEvSel1      = physioset.event.class_selector('Type', '__PeriodicEvent');
    myEvSel2      = physioset.event.value_selector(3);
    myEvSelector  = physioset.event.cascade_selector(myEvSel1, myEvSel2);
    mySelector1   = pset.selector.sensor_idx(1);
    mySelector2   = pset.selector.good_data;
    mySelector3   = pset.selector.event_selector('EventSelector', myEvSelector);
    
    mySelector    = pset.selector.cascade(mySelector1, mySelector2, mySelector3);
    myNode2       = meegpipe.node.subset.new('DataSelector', mySelector);
    
    myPipe = meegpipe.node.pipeline.new(...
        'NodeList',         {myNode1, myNode2}, ...
        'GenerateReport',   false);
    data2 = run(myPipe, data);
    
    ok(size(data2,2) == 250 && all(data2(1,:) == 501:750), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% Cleanup
try
    
    name = 'cleanup';
    % just in case
    [~, ~] = system(sprintf('qdel -u %s', get_username));
    clear data dataCopy ans myCfg myNode;
    rmdir(session.instance.Folder, 's');
    session.clear_subsession();
    ok(true, name);
    
catch ME
    ok(ME, name);
end

%% Testing summary
status = finalize();