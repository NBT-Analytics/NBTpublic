function [status, MEh] = test_ecg()
% TEST_ECG- Tests ECG correction

import mperl.file.spec.*;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import oge.has_oge;
import mperl.config.inifiles.inifile;

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

%% process random data: no ECG components
try
    
    name = 'process random data: no ECG components';
    
    X = rand(4, 5000);
    
    eegSensors = sensors.eeg.from_template('egi256', 'PhysDim', 'uV');
    
    eegSensors = subset(eegSensors, 1:4);
    
    importer = physioset.import.matrix(250, 'Sensors', eegSensors);
    
    data = import(importer, X);
    
    myNode = meegpipe.node.bss.ecg('GenerateReport', false);
    run(myNode, data);
    
    X = X - repmat(mean(X, 2), 1, size(X,2));
    
    ok(max(abs(data(:)-X(:))) < 1e-2, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% process real EEG data
try
    
    name = 'process real EEG data';
    
    if exist('20131121T171325_647f7.pseth', 'file') > 0,
        data = pset.load('20131121T171325_647f7.pseth');
    else
        % Try downloading the file
        url = 'http://kasku.org/data/meegpipe/20131121T171325_647f7.zip';
        unzipDir = catdir(session.instance.Folder, '20131121T171325_647f7');
        unzip(url, unzipDir);
        fileName = catfile(unzipDir, '20131121T171325_647f7.pseth');
        data = pset.load(fileName);
    end
    dataCopy = copy(data);
    
    % Remove PWL noise that can confuse the ECG node
    filter(filter.lpfilt('fc', 40/(dataCopy.SamplingRate/2)), dataCopy);
    
    myCrit = get_config(meegpipe.node.bss.ecg, 'Criterion');
    
    myNode = meegpipe.node.bss.ecg(...
        'Criterion',        myCrit, ...
        'GenerateReport',   true, ...
        'IOReport',         report.plotter.io);
    warning('off', 'snapshots:TooManyVertices');
    newData = run(myNode, dataCopy);
    warning('on', 'snapshots:TooManyVertices');
    
    center(data);
    
    cfgFile = catfile(get_full_dir(myNode, dataCopy), [get_name(myNode) '.ini']);
    cfg = inifile(cfgFile);
    icSelection = val(cfg, 'bss', 'selection', true);
    icSelection = cellfun(@(x) str2double(x), icSelection);
    
    ok(max(abs(data(:)-newData(:))) > 100 && ...
        numel(icSelection) == 1 && icSelection == 1, name);
    
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