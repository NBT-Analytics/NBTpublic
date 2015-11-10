function [status, MEh] = test1()
% TEST1 - Tests basic node functionality

import mperl.file.spec.*;
import meegpipe.node.*;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import oge.has_oge;
import misc.get_username;

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
    abp_features.new;
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% constructor with config options
try
    
    name = 'constructor with config options';
    myNode = abp_features.new('FirstLevel', {@(x) mean(x)}, ...
        'FeatureNames', {'data_mean'});
    
    featNames = get_config(myNode, 'FeatureNames');
    ok(numel(featNames) == 1 && ismember(featNames, 'data_mean'), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% process sample data
try
    
    name   = 'process sample data';
    
    tmp = load(catfile(meegpipe.root_path, '+data', 'abp.mat'), 'abp');
    abp = tmp.abp;
    
    mySensors  = sensors.physiology('Label', 'BP');
    myImporter = physioset.import.matrix('Sensors', mySensors, ...
        'SamplingRate', 512);
    
    data = import(myImporter, abp);
  
    myPipe = pipeline.new('NodeList', ...
        {abp_beat_detect.new, abp_features.new});
    
    run(myPipe, data);
    
    % ensure the imported and original data are identical
    ok(numel(get_event(data))>0, name);
    clear data;
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% Cleanup
try
    
    name = 'cleanup';
    % just in case
    [~, ~] = system(sprintf('qdel -u %s', get_username));
    clear data dataCopy myNode;
    rmdir(session.instance.Folder, 's');
    session.clear_subsession();
    ok(true, name);
    
catch ME
    ok(ME, name);
end

%% Testing summary
status = finalize();