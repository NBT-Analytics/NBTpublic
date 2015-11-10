function [status, MEh] = test_eog_regr()
% TEST_EOG_REGR- Tests EOG correction using regression

import mperl.file.spec.*;
import test.simple.*;
import meegpipe.node.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import oge.has_oge;

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

%% Constructor
try
    
    name = 'constructors';
    aar.eog.regression;
    aar.eog.eog;
   
    aar.eog.regression('Order', 5, 'EOGChannels', 1);  

    ok(true, name);
    
catch ME
    
    ok(ME, name);
    status = finalize();
    return;
    
end

%% adaptive regression
try
    
    name = 'adaptive regression';
    
    data = sample_eeglab_data();
   
    myNode = aar.eog.adaptive_regression('GenerateReport', false, ...
        'Save', false);
    
    dataO = data(:,:);
    run(myNode, data);    
    
    ok(max(data(:)-dataO(:)) > 0.1, name);
    
catch ME
    
    ok(ME, name);
    status = finalize();
    return;
    
end

%% Cleaning EEGLAB's sample dataset
try
    
    name = 'Cleaning EEGLAB''s sample dataset';
    
    data = sample_eeglab_data();
   
    myNode = aar.eog.regression('GenerateReport', false, 'Save', false);
    
    dataO = data(:,:);
    run(myNode, data);    
    
    ok(max(data(:)-dataO(:)) > 0.1, name);
    
catch ME
    
    ok(ME, name);
    status = finalize();
    return;
    
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

end

function data = sample_eeglab_data(type)

import pset.session;
import mperl.file.spec.catfile;
import mperl.file.spec.catdir;

if nargin < 1 || isempty(type),
    type = 'epochs';
end

if strcmp(type, 'epochs'),
    dataName = 'eeglab_data_epochs_ica';
else
    % Sensors 2 and 6 are EOG channels
    dataName = 'eeglab_data';
end

fileName = [dataName '.set'];

if ~exist(fileName, 'file') > 0,   
    % Try downloading the file
    url = ['http://kasku.org/data/meegpipe/' dataName  '.zip'];
    unzipDir = catdir(session.instance.Folder, dataName);
    unzip(url, unzipDir);
    fileName = catfile(unzipDir, fileName);   
end

warning('off', 'sensors:InvalidLabel');
warning('off', 'sensors:MissingPhysDim');
data = import(physioset.import.eeglab, fileName);
warning('on', 'sensors:InvalidLabel');
warning('on', 'sensors:MissingPhysDim');
end