function [status, MEh] = test_fif_angus()
% TEST_FIF_ANGUS - Tests importing the MEG .fif files provided by Angus

import mperl.file.spec.*;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;

DATA_URL = 'http://dl.dropboxusercontent.com/u/4479286/meegpipe/';    
DATA_FILE = '030_2tg_rest.fif';

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

%% download sample data file
try
    name = 'download sample data file';
  
    if ~exist(DATA_FILE, 'file'),
        urlwrite([DATA_URL DATA_FILE], [pwd filesep DATA_FILE]);
    end
    ok(exist(DATA_FILE, 'file') > 0, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% import sample data
try
    
    name = 'import sample data file';   
   
    myImporter = physioset.import.fileio;
    data = import(myImporter, DATA_FILE);
  
    evalc('dataFt = ft_read_data(DATA_FILE);');
    
    rawIdx = get_meta(data, 'raw_chan_indexing');
    dataFt = dataFt(rawIdx,:); %#ok<NODEF>
    
    mySens = sensors(data);
    condition  = ...
        all(size(data) == size(dataFt)) && ...
        max(abs(data(:) - dataFt(:))) < 0.001 && ...
        nb_sensors(mySens) == 320 && ...
        isa(mySens, 'sensors.mixed') && ...
        numel(mySens.Sensor) == 4 && ...
        ~any(isnan(mySens.Sensor{1}.Cartesian(:))) && ...
        ~any(isnan(mySens.Sensor{2}.Cartesian(:))); 
    clear data;
    ok(condition, name);
    
    
catch ME

    clear data;
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