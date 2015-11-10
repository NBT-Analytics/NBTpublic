function [status, MEh] = test_basic()
% TEST_BASIC - Tests basic node functionality

import mperl.file.spec.*;
import meegpipe.node.*;
import meegpipe.node.qrs_detect.qrs_detect;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import oge.has_oge;
import misc.get_username;
import physioset.event.std.qrs;

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
    status = finalize();
    return;
    
end


%% default constructor
try
    
    name = 'constructor';
    obs.new; 
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% constructor from config object
try
    
    name = 'constructor from config object';
    myCfg = obs.config('NPC',4);
    obs.new(myCfg);
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% process sample data
try
    
    name   = 'process sample data';    
   
    ecgSens = sensors.physiology('Label', 'ECG');
    eegSens = sensors.eeg.dummy(5);
    sens = sensors.mixed(eegSens, ecgSens);
    myImporter = physioset.import.matrix('Sensors', sens);
    X = randn(6, 10000);
    data = import(myImporter, X);
    
    % Add some artificial QRS complex events
    add_event(data, qrs(1:100:10000));
    
    myNode = obs.new;
    
    run(myNode, data);
    
    % ensure the imported and original data are identical
    ok(max(abs(data(:)-X(:)))>0.1, name);
    clear data;
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% process real data
try
    
    name = 'process real data';
    
    myData = real_data;
    
    myPipe = pipeline.new(...
        qrs_detect.new, ...
        obs.new, ...
        'Save', false, 'GenerateReport', true ...
        );
    
    dataO = myData(1,:);
    run(myPipe, myData);
    
    ok(prctile(myData(1,:), 90) < 0.75*prctile(dataO, 90), name);
    
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

end


function dataCopy = real_data()

import pset.session;
import mperl.file.spec.catfile;
import mperl.file.spec.catdir;

unzipDir = catdir(session.instance.Folder, 'bcg_sample2');
fileName = catfile(unzipDir, 'bcg_sample2.pseth');

if exist('bcg_sample.pseth', 'file') > 0,
    data = pset.load('bcg_sample2.pseth');
elseif exist('bcg_sample2.zip', 'file') > 0
    unzip('bcg_sample2.zip', unzipDir);
    data = pset.load(fileName);
else
    % Try downloading the file
    url = 'http://kasku.org/data/meegpipe/bcg_sample2.zip';    
    unzip(url, unzipDir);    
    data = pset.load(fileName);
end
dataCopy = copy(data);

end