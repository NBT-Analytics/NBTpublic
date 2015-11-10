function [status, MEh] = test2()
% TEST2 - Test edfplus importer

import mperl.file.spec.*;
import physioset.import.edfplus;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;

% The sample data file to be used for testing
% You may have to edit some of the tests below if you change this URL
DATA_URL = ['http://kasku.org/data/meegpipe/' ...
    'pupw_0005_physiology_afternoon-sitting_day1.edf'];

MEh     = [];

initialize(8);

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
    edfplus;
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% contructor with signal type
try
    
    name = 'contructor with signal type';
    obj = edfplus('SignalType', 'ECG');
    ok(strcmpi(obj.SignalType, 'ecg'), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% download sample data file
try
    name = 'download sample data file';
    
    folder = session.instance.Folder;
    file = catfile(folder, 'sample.edf');
    urlwrite(DATA_URL, file);
    
    ok(exist(file, 'file') > 0, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% import sample data
try
    
    name = 'import sample data file';
    
    folder = session.instance.Folder;
    file = catfile(folder, 'sample.edf');
    warning('off', 'import:invalidFormat');
    data = import(edfplus, file);
    warning('on', 'import:invalidFormat');
    
    condition = all(size(data) == [5 1064960]) & ...
        isa(sensors(data), 'sensors.physiology');
    clear data;
    ok(condition, name);
    
    
catch ME
    
    warning('on', 'import:invalidFormat');
    clear data;
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% import multiple files
try
    
    name = 'import multiple files';
    folder = session.instance.Folder;
    file1 = catfile(folder, 'sample.edf');
    file2 = catfile(folder, 'sample2.edf');
    copyfile(file1, file2);
    warning('off', 'import:invalidFormat');
    data = import(edfplus, file1, file2);
    warning('on', 'import:invalidFormat');
    
    condition = iscell(data) && numel(data) == 2 && ...
        all(size(data{1})==size(data{2}));
    
    clear data;
    
    ok(condition, name);
    
catch ME
    
    warning('on', 'import:invalidFormat');
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% specify file name
try
    
    name = 'specify file name';
    
    folder = session.instance.Folder;
    fileIn = catfile(folder, 'sample.edf');
    warning('off', 'import:invalidFormat');
    import(edfplus('FileName', catfile(folder, 'myfile')), fileIn);
    warning('on', 'import:invalidFormat');
    
    psetExt = pset.globals.get.DataFileExt;
    newFile = catfile(folder, ['myfile' psetExt]);
    ok(exist(newFile, 'file') > 0, name);
    
catch ME
    
    warning('on', 'import:invalidFormat');
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Cleanup
try
    
    name = 'cleanup';
    clear data;
    rmdir(session.instance.Folder, 's');
    session.clear_subsession();
    ok(true, name);
    
catch ME
    ok(ME, name);
end

%% Testing summary
status = finalize();