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

DATA_URL = ['http://kasku.org/data/meegpipe/' ...
    'pupw_0001_pupillometry_afternoon-sitting_1.csv'];

initialize(6);

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
    generic_features.new; 
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% constructor with config options
try
    
    name = 'constructor with config options';
    generic_features.new('FirstLevel', @(x) median(x));
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% process sample data: no SecondLevel
try
    
    name = 'process sample data: no SecondLevel';
    
    % random data with sinusolidal trend
    folder = session.instance.Folder;    
    file = catfile(folder, 'sample.csv');
    urlwrite(DATA_URL, file);    
    warning('off', 'sensors:InvalidLabel');
    data = import(physioset.import.pupillator, file);
    warning('on', 'sensors:InvalidLabel');
    
    mySel{1} = pset.selector.event_selector(value_selector(4,5,7));
    mySel{2} = pset.selector.event_selector(value_selector(2,3));
    mySel{3} = pset.selector.event_selector(value_selector(8));
    
    myFirstLevelFeature  = @(x, ev, dataSel) mean(x(:));
  
    myNode = generic_features.new(...
        'TargetSelector', mySel, ...
        'FirstLevel',     myFirstLevelFeature, ...
        'SecondLevel',    [], ...
        'FeatureNames',   {'mean'});
    
    data = run(myNode, data);
    
    featFile = catfile(get_full_dir(myNode, data), 'features.txt');
    condition = exist(featFile, 'file') > 0;
    
    if condition,
        [~, ~, rownames] = misc.dlmread(featFile, ',', [], 1);
        condition =  condition & numel(rownames) == 3;
        if condition
            for i = 1:3
                condition = condition & strcmp(rownames{i}, ...
                    get_name(mySel{i}));
            end
        end
    end
    
    delete(file);
    data.Temporary = true;
    clear data ans;
        
    ok(condition, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% process sample data
try
    
    name = 'process sample data';
    
    % random data with sinusolidal trend
    folder = session.instance.Folder;    
    file = catfile(folder, 'sample.csv');
    urlwrite(DATA_URL, file);    
    warning('off', 'sensors:InvalidLabel');
    data = import(physioset.import.pupillator, file);
    warning('on', 'sensors:InvalidLabel');
    
    mySel1 = pset.selector.event_selector(value_selector(4,5,7));
    mySel2 = pset.selector.event_selector(value_selector(2,3));
    mySel3 = pset.selector.event_selector(value_selector(8));
    
    myFirstLevelFeature  = @(x, ev, dataSel) mean(x(:));
    mySecondLevelFeature = {@(x, ev, selectorObj) x{1}/x{2}, ...
        @(x, selectorEvs, selectorArray) mean(cell2mat(x))};
    
    myNode = generic_features.new(...
        'TargetSelector', {mySel1, mySel2, mySel3}, ...
        'FirstLevel',     myFirstLevelFeature, ...
        'SecondLevel',    mySecondLevelFeature, ...
        'FeatureNames',   {'funnyratio1', 'funnyratio2'});
    
    data = run(myNode, data);    
   
    featFile = catfile(get_full_dir(myNode, data), 'features.txt');
    condition = exist(featFile, 'file') > 0;
    
    if condition,
        [~, hdr] = misc.dlmread(featFile, ',');
        condition =  condition & numel(hdr) == 2;
        if condition
            condition = condition & ...
                all(ismember(hdr, {'funnyratio1', 'funnyratio2'}));
        end
    end
    
    delete(file);
    data.Temporary = true;
    clear data ans;

    ok(condition, name);
    
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