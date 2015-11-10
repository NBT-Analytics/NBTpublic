function [status, MEh] = test_basic()
% test_basic - Tests basic node functionality

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

initialize(7);

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
    myNode = reref.new; %#ok<NASGU>
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% process sample data
try
    
    name = 'process sample data';
    myNode = reref.new; % The identity re-reference operator
    
    X = 3+randn(10, 1000);
    
    mySensors = subset(sensors.eeg.from_template('egi256'), 1:10);
    myImporter = physioset.import.matrix('Sensors', mySensors);
    data = import(myImporter, X);
    run(myNode, data);
    
    ok(max(abs(X(:)-data(:))) < .15, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% average reference
try
    
    name = 'average reference';
    
    myNode = reref.avg;
    
    X = 3+randn(10, 1000);
    mySensors = subset(sensors.eeg.from_template('egi256'), 1:10);
    myImporter = physioset.import.matrix('Sensors', mySensors);
    data = import(myImporter, X);
    
    Xmean = mean(X);
    run(myNode, data);
    
    ok(max(max(abs(X-repmat(Xmean, 10, 1)-data(:,:)))) < 0.01, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% linked reference
try
    
    name = 'linked reference';
    
    myNode = reref.linked('EEG 1', 'EEG 2');
    
    X = 3+randn(10, 1000);
    mySensors = subset(sensors.eeg.from_template('egi256'), 1:10);
    myImporter = physioset.import.matrix('Sensors', mySensors);
    data = import(myImporter, X);
    
    Xmean = mean(X(1:2,:));
    run(myNode, data);
    
    ok(max(max(abs(X-repmat(Xmean, 10, 1)-data(:,:)))) < 0.01, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% process multiple files
try
    
    name = 'process multiple datasets';
    
    data = cell(1, 3);
    mySensors = subset(sensors.eeg.from_template('egi256'), 1:10);
    myImporter = physioset.import.matrix('Sensors', mySensors);
    for i = 1:3,   
        X = randn(10, 1000);
        data{i} = import(myImporter, X);
    end
    myNode = reref.new('OGE', false);
    run(myNode, data{:});
    ok(max(max(abs(data{3}(:,:)-X(:,:)))) < 1e-3, name);
    
    
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