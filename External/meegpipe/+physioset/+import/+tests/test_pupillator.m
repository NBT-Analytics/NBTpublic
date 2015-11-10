function [status, MEh] = test_pupillator()
% TEST_PUPILLATOR - Test importer for Wisse&Joris pupillometry measurements

import mperl.file.spec.*;
import physioset.import.pupillator;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;

MEh     = [];
REMOTE  = meegpipe.get_config('test', 'remote');

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
    pupillator;
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% download sample data file
try
    name = 'download sample data files';
    
    folder = session.instance.Folder;
    file = catfile(folder, 'sample.csv');
    url = [REMOTE 'pupw_0001_pupillometry_afternoon-sitting_1.csv'];
    urlwrite(url, file);
    fileNewPupillator = catfile(folder, 'sample_new_pupillator.csv');
    url = [REMOTE 'jestest.csv'];
    urlwrite(url, fileNewPupillator);
    ok(exist(file, 'file') > 0 & exist(fileNewPupillator, 'file') > 0, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% import sample data
try
    
    name = 'import sample data file';
    
    warning('off', 'sensors:InvalidLabel');
    warning('off', 'sensors:MissingPhysDim');
    data = import(pupillator, file);
    warning('on', 'sensors:MissingPhysDim');
    warning('on', 'sensors:InvalidLabel');
    
    evArray = get_event(data);
    
    ok(...
        all(size(data) == [2 52508])    && ...
        numel(evArray) == 246   && ...
        evArray(1).Duration == 1500, ...
        name);
    
    clear data;
    
    
catch ME
    
    warning('on', 'sensors:MissingPhysDim');
    warning('on', 'sensors:InvalidLabel');
    clear data;
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% import sample data (pupillator 2.0)
try
    
    name = 'import sample data (pupillator 2.0)';
    
    warning('off', 'sensors:InvalidLabel');
    warning('off', 'sensors:MissingPhysDim');
    data = import(pupillator, fileNewPupillator);
    warning('on', 'sensors:MissingPhysDim');
    warning('on', 'sensors:InvalidLabel');
    
    evArray = get_event(data);
    
    ok(...
        all(size(data) == [2 6238])     && ...
        numel(evArray) == 21            && ...
        numel(unique(evArray)) == 11    && ...
        evArray(1).Duration == 659      && ...
        strcmp(evArray(1).Type, 'R255G200B200'), ...
        name);
    
    clear data;
    
    
catch ME
    
    warning('on', 'sensors:MissingPhysDim');
    warning('on', 'sensors:InvalidLabel');
    clear data;
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% import multiple files
try
    
    name = 'import multiple files';
    folder = session.instance.Folder;
    file2 = catfile(folder, 'sample_copy.mff');
    copyfile(file, file2);
    
    warning('off', 'sensors:InvalidLabel');
    warning('off', 'sensors:MissingPhysDim');
    warning('off', 'equalize:ZeroVarianceData')
    data = import(pupillator, file, file2);
    warning('on', 'equalize:ZeroVarianceData')
    warning('on', 'sensors:MissingPhysDim');
    warning('on', 'sensors:InvalidLabel');
    
    
    condition = iscell(data) && numel(data) == 2 && ...
        all(size(data{1})==size(data{2}));
    
    clear data;
    
    ok(condition, name);
    
catch ME
    
    warning('on', 'sensors:MissingPhysDim');
    warning('on', 'sensors:InvalidLabel');
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% specify file name
try
    
    name = 'specify file name';
    
    folder = session.instance.Folder;
    
    warning('off', 'sensors:InvalidLabel');
    warning('off', 'sensors:MissingPhysDim');
    warning('off', 'equalize:ZeroVarianceData')
    import(pupillator('FileName', catfile(folder, 'myfile')), file);
    warning('on', 'equalize:ZeroVarianceData')
    warning('on', 'sensors:MissingPhysDim');
    warning('on', 'sensors:InvalidLabel');
    
    psetExt = pset.globals.get.DataFileExt;
    newFile = catfile(folder, ['myfile' psetExt]);
    ok(exist(newFile, 'file') > 0, name);
    
catch ME
    
    warning('on', 'sensors:MissingPhysDim');
    warning('on', 'sensors:InvalidLabel');
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