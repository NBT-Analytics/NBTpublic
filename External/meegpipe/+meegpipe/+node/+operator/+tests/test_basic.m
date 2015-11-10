function [status, MEh] = test_basic()
% TEST_BASIC - Tests basic node functionality

import mperl.file.spec.*;
import meegpipe.node.*;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import oge.has_oge;
import physioset.event.value_selector;

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
    operator.new; 
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% constructor with config options
try
    
    name = 'constructor with config options';
    myNode = operator.new('Operator', @(x) 0);
    
    op = get_config(myNode, 'Operator');
    ok(op(rand(1,10)) == 0, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Apply scaling operator
try
    
    name = 'Apply scaling operator';
    
   
    data = import(physioset.import.matrix, rand(5,1000));
    
    myNode = operator.new(...
        'Operator',         @(x) 0.5*x, ...
        'DataSelector',     pset.selector.sensor_idx(2));
    
    origData = data(1:2,:);
    
    data = run(myNode, data);  
        
    scaling = mean(origData(2,:)./data(2,:));
    
    scaling2 = mean(origData(1,:)./data(1,:));
    
    ok(scaling > 1.9 & scaling < 2.1 & scaling2 > 0.99 & scaling2 < 1.1, name);
    
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