function [status, MEh] = test_var()
% test_var - Tests var criterion

import mperl.file.spec.*;
import meegpipe.node.*;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import oge.has_oge;

MEh     = [];

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
    MEh = [MEh ME];
    
end


%% default constructor
try
    
    name = 'constructor';
    bad_channels.criterion.var.new;
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% use logarithmic variances
try
    
    name = 'use logarithmic variances';
    
    X = 10*randn(34, 15000);
    X(31,:) = 50*X(31,:);
    X(10,:) = eps*X(1,:);
    X(20,:) = 0;
    
    warning('off', 'sensors:InvalidLabel');
    eegSensors = sensors.eeg.from_template('egi256', 'PhysDim', 'uV');
    warning('on', 'sensors:InvalidLabel');
    
    eegSensors   = subset(eegSensors, 1:8:256);
    dummySensors = sensors.dummy(2);
    allSensors   = sensors.mixed(eegSensors, dummySensors);
    
    importer = physioset.import.matrix(100, 'Sensors', allSensors);
    data = import(importer, X);
    
    set_bad_sample(data, 50:2500);
    
    crit = meegpipe.node.bad_channels.criterion.var.var(...
        'Min',          @(x) mad(x) - 10, ...
        'Max',          @(x) mad(x) + 5, ...     
        'LogScale',     true);
    
    dataSel = pset.selector.sensor_class('Class', 'eeg');
    myNode = bad_channels.new('Criterion', crit, 'DataSelector', dataSel);
    run(myNode, data);
    
    badSel = find(is_bad_channel(data));
    
    ok(numel(badSel) == 3 && all(badSel == [10 20 31]), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% use non-logarithmic variances
try
    
    name = 'use non-logarithmic variances';
    
    X = 10*randn(34, 15000);
    X(31,:) = 50*X(31,:);
    X(10,:) = eps*X(1,:);
    X(20,:) = 0;
    
    warning('off', 'sensors:InvalidLabel');
    eegSensors = sensors.eeg.from_template('egi256', 'PhysDim', 'uV');
    warning('on', 'sensors:InvalidLabel');
    
    eegSensors   = subset(eegSensors, 1:8:256);
    dummySensors = sensors.dummy(2);
    allSensors   = sensors.mixed(eegSensors, dummySensors);
    
    importer = physioset.import.matrix(100, 'Sensors', allSensors);
    data = import(importer, X);
    
    set_bad_sample(data, 50:2500);
    
    crit = meegpipe.node.bad_channels.criterion.var.var(...
        'Min',          @(x) 0.001*median(x), ...
        'Max',          @(x) mad(x) + 2, ...
        'LogScale',     false, ...
        'NN',           Inf);
    
    dataSel = pset.selector.sensor_class('Class', 'eeg');
    myNode = bad_channels.new('Criterion', crit, 'DataSelector', dataSel);
    run(myNode, data);
    
    badSel = find(is_bad_channel(data));
    
    ok(numel(badSel) == 3 && all(badSel == [10 20 31]), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% zscores configuration
try
    
    name = 'zscores configuration';
    
    X = 10*randn(34, 15000);
    X(31,:) = 50*X(31,:);
    X(10,:) = eps*X(1,:);
    X(20,:) = 0;
    
    warning('off', 'sensors:InvalidLabel');
    eegSensors = sensors.eeg.from_template('egi256', 'PhysDim', 'uV');
    warning('on', 'sensors:InvalidLabel');
    
    eegSensors   = subset(eegSensors, 1:8:256);
    dummySensors = sensors.dummy(2);
    allSensors   = sensors.mixed(eegSensors, dummySensors);
    
    importer = physioset.import.matrix(100, 'Sensors', allSensors);
    data = import(importer, X);
    
    set_bad_sample(data, 50:2500);
    
    crit = meegpipe.node.bad_channels.criterion.var.zscore;
    
    dataSel = pset.selector.sensor_class('Class', 'eeg');
    myNode = bad_channels.new('Criterion', crit, 'DataSelector', dataSel);
    run(myNode, data);
    
    badSel = find(is_bad_channel(data));
    
    ok(numel(badSel) == 1 && all(badSel == 31), name);
    
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
    MEh = [MEh ME];
end

%% Testing summary
status = finalize();