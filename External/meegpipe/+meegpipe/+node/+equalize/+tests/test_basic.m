function [status, MEh] = test_basic()
% TEST_BASIC - Tests basic node functionality

import mperl.file.spec.*;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import oge.has_oge;
import physioset.event.value_selector;

DATA_URL = 'http://dl.dropboxusercontent.com/u/4479286/meegpipe/';    
DATA_FILE = '030_2tg_rest.fif';

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

%% equalize sample data
try
    
    name = 'equalize sample data';   
   
    myImporter = physioset.import.fileio;
    data = import(myImporter, DATA_FILE);
    
    [~, sensIdx] = sensor_groups(sensors(data));
    origVar = nan(numel(sensIdx), 1);
    for i = 1:numel(sensIdx)
        select(data, sensIdx{i});
        origVar(i) = median(var(data, [], 2));
        restore_selection(data);
    end
    
    myNode = meegpipe.node.equalize.new;
    
    run(myNode, data);
    
    newVar = nan(numel(sensIdx), 1);
    for i = 1:numel(sensIdx)
        select(data, sensIdx{i});
        newVar(i) = median(var(data, [], 2));
        restore_selection(data);
    end
    
    condition = ...
        newVar(origVar < 1e-50) == origVar(origVar < 1e-50) && ...
        abs(mean(newVar(origVar > 1e-50))-1) < 0.001;

    clear data;
    ok(condition, name);
    
    
catch ME

    clear data;
    ok(ME, name);
    MEh = [MEh ME];
    
end



%% default constructor
try
    
    name = 'constructor';
    meegpipe.node.equalize.new; 
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% download sample data file
try
    name = 'download sample data file';
  
    if ~exist(DATA_FILE, 'file'),
        urlwrite([DATA_URL DATA_FILE], [pwd filesep DATA_FILE]);
    end
    ok(exist(DATA_FILE, 'file') > 0, name);
    
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