function [status, MEh] = test_fif()
% TEST_FIF - Tests importing MEG .fif files

import mperl.file.spec.*;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;

DATA_URL = meegpipe.get_config('test', 'remote');    
DATA_FILE = 'abcg_0002_meg_task_2_8_raw.fif';

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
        urlwrite([DATA_URL DATA_FILE '.gz'], [pwd filesep DATA_FILE '.gz']);
        gunzip([pwd filesep DATA_FILE '.gz']);
    elseif exist([pwd filesep DATA_FILE '.gz'], 'file'),
        gunzip([pwd filesep DATA_FILE '.gz']);
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
    
    condition  = all(size(data) == size(dataFt)) && ...
        max(abs(data(:) - dataFt(:))) < 0.001; 
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