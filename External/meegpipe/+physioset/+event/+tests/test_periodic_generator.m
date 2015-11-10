function [status, MEh] = test_periodic_generator()
% TEST_PERIODIC_GENERATOR - Tests event generators


import physioset.event.*;
import physioset.event.std.*;
import test.simple.*;
import datahash.DataHash;
import pset.session;
import meegpipe.node.*;

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

%% periodic generator with overlapping epochs
try
    
    name = 'periodic generator with overlapping epochs';
    % A toy dataset sampled at 1 sample per second
    myData = import(physioset.import.matrix('SamplingRate', 1), randn(1,100));
    myGen = physioset.event.periodic_generator('Period', 5, 'Duration', 10);
    evs = generate(myGen, myData);
    
    % Get the end-points of each event-delimited epoch and ensure they
    % don't go beyond the data duration
    epoch_ends = get(evs, 'Sample') + get(evs, 'Duration') - 1;
    ok(all(epoch_ends <= size(myData,2)), name)
    
catch ME
    
    ok(ME,name)
    MEh = [MEh ME];
    
end

%% default constructors
try
    
    name = 'default constructors';
    sleep_scores_generator;
    periodic_generator;
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Cleanup
try
    
    name = 'cleanup'; 
    clear data dataCopy ans myCfg myNode;
    rmdir(session.instance.Folder, 's');
    session.clear_subsession();
    ok(true, name);
    
catch ME
    ok(ME, name);
end


%% Testing summary
status = finalize();

end


