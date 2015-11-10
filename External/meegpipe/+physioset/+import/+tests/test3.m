function [status, MEh] = test3()
% TEST2 - Test mff importer

import mperl.file.spec.*;
import physioset.import.mff;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;

% The sample data file to be used for testing
% You may have to edit some of the tests below if you change this URL
DATA_URL = ['http://kasku.org/data/meegpipe/' ...
    'test_mux.mff.tgz'];

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
    mff;
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% download sample data file
try
    name = 'download sample data file';
    
    folder = session.instance.Folder;    
    file = untar(DATA_URL, folder);
    file = file{1};
    folderSc = strrep(folder, '\', '\\');
    file = regexprep(file, [folderSc '.(.+)(\\|/).+$'], '$1');    
    file = catfile(folder, file);
    ok(exist(file, 'file') > 0, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% import sample data
try
    
    name = 'import sample data file';   
    
    warning('off', 'sensors:InvalidLabel');
    warning('off', 'sensors:MissingPhysDim');
    data = import(mff, file);
    warning('on', 'sensors:MissingPhysDim');
    warning('on', 'sensors:InvalidLabel');
    
    condition = all(size(data) == [275 94697]) & ...
        isa(sensors(data), 'sensors.mixed');
    clear data;
    ok(condition, name);
    
    
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
    file2 = catfile(folder, 'copy.mff');
    copyfile(file, file2);
    
    warning('off', 'sensors:InvalidLabel');
    warning('off', 'sensors:MissingPhysDim');
    data = import(mff, file, file2);
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
    import(mff('FileName', catfile(folder, 'myfile')), file);
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

%% Unmultiplex data channel
try
    
    name = 'unmultiplex mux data channel';
  
    warning('off', 'sensors:InvalidLabel');
    warning('off', 'sensors:MissingPhysDim');
    data = import(mff, file);
    warning('on', 'sensors:MissingPhysDim');
    warning('on', 'sensors:InvalidLabel');
    
    % Get the pip box channels   
    % Not sure if the 26.3089 value is the correct one...
    condition = size(data,1) == 275 & ...
        abs(mean(data(end,:))) - 16.2089 < 0.1;
    ok(condition, name);
    
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