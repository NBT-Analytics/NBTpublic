function [status, MEh] = test1()
% TEST1 - Tests basic package functionality

import test.simple.*;
import mperl.file.spec.*;
import pset.selector.*;
import sensors.*;
import pset.session;
import misc.rmdir;
import datahash.DataHash;

MEh     = [];

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


%% default constructors
try
    
    name = 'default constructors';
    cascade;
    good_data;
    sensor_group_idx;
    sensor_idx;
    all_data;
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% construction arguments
try
    
    name = 'construction arguments';
    sel1 = sensor_group_idx(1:5);
    sel2 = sensor_idx(1:10);
    sel3 = good_data;
    cascade(sel1, sel2, sel3);
    ok( true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% sensor_group_idx
try
    
    name = 'sensor_group_idx';
    
    % Create three independent sensor groups
    % (never mind about sensor labels)
    sg1 = dummy(5);
    sg2 = dummy(5);
    sg3 = dummy(5);
    
    % Put them together into a mixed sensor array
    mySensors = mixed(sg1, sg2, sg3);
    
    % Create sample physioset
    X = randn(15, 1000);
    importer = physioset.import.matrix(250, 'Sensors', mySensors);
    data = import(importer, X);
    
    % Select only the first and third sensor groups
    mySelector = sensor_group_idx(1, 3);
    select(mySelector, data);
    
    % Must be OK
    X = X([1:5, 11:15],:);
    ok(size(data,1) == 10 && max(abs(data(:) - X(:)))<1e-3, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% good_data
try
    
    name = 'good_data';
    
    % Create sample physioset
    X = randn(10,1000);
    data = import(physioset.import.matrix, X);
    
    % Mark some bad samples and bad channels
    set_bad_channel(data, 4:5);
    set_bad_sample(data, 100:500);
    
    % Construct a selector object
    mySelector = good_data;
    
    % Select good data from out sample dataset
    select(mySelector, data);
    
    X = X([1:3 6:10], [1:99 501:1000]);
    ok(size(data,1) == 8 && size(data,2) == 599 && ...
        max(abs(data(:) - X(:)))<1e-3, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% sensor_idx
try
    
    name = 'sensor_idx';
    
    % Create three independent sensor groups
    % (never mind about sensor labels)
    sg1 = dummy(5);
    sg2 = dummy(5);
    sg3 = dummy(5);
    
    mySensors = mixed(sg1, sg2, sg3);
    
    X = randn(15, 1000);
    importer = physioset.import.matrix( 250, 'Sensors', mySensors);
    data = import(importer, X);

    mySelector = sensor_idx(1:7);
    select(mySelector, data);

    X = X(1:7,:);
    ok(size(data,1) == 7 && max(abs(data(:) - X(:)))<1e-3, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% ~sensor_idx
try
    
    name = '~sensor_idx';

    sg1 = sensors.dummy(5);
    sg2 = sensors.dummy(5);
    sg3 = sensors.dummy(5);

    mySensors = sensors.mixed(sg1, sg2, sg3);
    
    X = randn(15, 1000);
    importer = physioset.import.matrix( 250, 'Sensors', mySensors);
    data = import(importer, X);
    
    mySelector = pset.selector.sensor_idx(1:7);
    select(~mySelector, data);

    X = X(8:end,:);
    ok(size(data,1) == 8 && max(abs(data(:) - X(:)))<1e-3, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% cascade
try
    
    name = 'cascade';
    % Create three independent sensor groups
    % (never mind about sensor labels)
    sg1 = dummy(5);
    sg2 = dummy(5);
    sg3 = dummy(5);
    
    % Put them together into a mixed sensor array
    mySensors = mixed(sg1, sg2, sg3);
    
    % Create sample physioset
    X = randn(15, 1000);
    importer = physioset.import.matrix( 250, 'Sensors', mySensors);
    data = import(importer, X);
    
    % Select only the first 7 channels
    mySelector = sensor_idx(1:7);
    select(mySelector, data);
    
    % Must be OK
    X = X(1:7,:);
    ok(size(data,1) == 7 && max(abs(data(:) - X(:)))<1e-3, name);
    
    
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% sensor_class (1)
try
    
    name = 'sensor_class (1)';
    % Create three independent sensor groups
    % (never mind about sensor labels)
    sg1 = sensors.dummy(5);
    sg2 = sensors.physiology('Label', {'ECG 1', 'ECG 2'});
    sg3 = sensors.eeg.dummy(10);
    
    % Put them together into a mixed sensor array
    mySensors = sensors.mixed(sg1, sg2, sg3);
    
    % Create sample physioset
    X = randn(17, 1000);
    data = import(physioset.import.matrix(250, 'Sensors', mySensors), X);
    
    % Select only the ECG channels
    mySelector = sensor_class('Type', 'ECG');
    select(mySelector, data);
    
    % Must be OK
    X1 = X(6:7,:);
    ok(size(data,1) == 2 && max(abs(data(:) - X1(:)))<1e-3, name);   
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% sensor_class (2)
try
    
    name = 'sensor_class (2)';
    % Create three independent sensor groups
    % (never mind about sensor labels)
    sg1 = sensors.dummy(5);
    sg2 = sensors.physiology('Label', {'ECG 1', 'ECG 2'});
    sg3 = sensors.eeg.dummy(10);
    
    % Put them together into a mixed sensor array
    mySensors = sensors.mixed(sg1, sg2, sg3);
    
    % Create sample physioset
    X = randn(17, 1000);
    data = import(physioset.import.matrix(250, 'Sensors', mySensors), X);
    
    mySelector = sensor_class('Class', {'eeg', 'dummy'});
    select(mySelector, data);
    
    % Must be OK
    X2 = X([1:5 8:17], :);
    ok(size(data,1) == 15 && max(abs(data(:) - X2(:)))<1e-3, name);
    
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% sensor_label
try
    
    name = 'sensor_label';
    % Create three independent sensor groups
    % (never mind about sensor labels)
    sg1 = sensors.dummy(5);
    sg2 = sensors.physiology('Label', {'ECG 1', 'ECG 2'});
    sg3 = sensors.eeg.dummy(10);
    
    % Put them together into a mixed sensor array
    mySensors = sensors.mixed(sg1, sg2, sg3);
    
    % Create sample physioset
    X = randn(17, 1000);
    data = import(physioset.import.matrix(250, 'Sensors', mySensors), X);
    
    mySelector = sensor_label('EEG\s+[3-4]');
    select(mySelector, data);
    
    % Must be OK
    X2 = X(10:11, :);
    ok(size(data,1) == 2 && max(abs(data(:) - X2(:)))<1e-3, name);
    
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% reject_boundaries (1)
try
    
    name = 'reject_boundaries (1)';
    
    data = import(physioset.import.matrix, rand(3,1000));
    
    mySelector = reject_boundaries;
    select(mySelector, data);
    
    % Must be OK
    ok(all(size(data) == [3 1000]), name);
    
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% reject_boundaries (2)
try
    
    name = 'reject_boundaries (2)';
    
    data = import(physioset.import.matrix, rand(3,1000));
    
    mySelector = reject_boundaries(...
        'StartMargin', 100, 'EndMargin', @(x) round(0.1*size(x,2)));
    select(mySelector, data);
    
    % Must be OK
    ok(all(size(data) == [3 800]), name);
    
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% all_data
try
    
    name = 'all_data';
    
    data = import(physioset.import.matrix, rand(3,1000));
    
    origSize = size(data);
    select(all_data, data);
    
    % Must be OK
    ok(all(size(data) == origSize), name);
    
    
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