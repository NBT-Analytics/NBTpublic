function [status, MEh] = test_nbt()
% TEST_NBT - Test importer for NeuroBiomarkers Toolbox .mat files
%
% See also: physioset.import.nbt

import mperl.file.spec.*;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import misc.set_warning_status;

% The sample data file to be used for testing
DATA_FILE = 'NBT.S0021.090205.EOR1';
DATA_URL = meegpipe.get_config('test', 'remote');
WARN_IDS = { 'sensors:InvalidLabel', 'sensors:MissingPhysDim' };

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


%% default constructor
try
    
    name = 'constructor';
    physioset.import.nbt;
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% import sample data
try
    
    name = 'import sample data file';
    
    if ~exist([DATA_FILE '.mat'], 'file'),
        urlwrite([DATA_URL DATA_FILE '.mat'], [DATA_FILE '.mat']);
        urlwrite([DATA_URL DATA_FILE '_info.mat'], [DATA_FILE '_info.mat']);
    end   
    stat = set_warning_status(WARN_IDS, 'off');
    data = import(physioset.import.nbt, [DATA_FILE '_info.mat']);
    set_warning_status(WARN_IDS, stat);
    
    ok(all(size(data) == [129 59577]) & numel(get_event(data)) == 1, name);
    
    clear data;
    
    
catch ME
    
    ids = { 'sensors:MissingPhysDim', 'sensors:MissingPhysDim' };
    set_warning_status(ids, 'on');
    clear data;
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% specify file name
try
    
    name = 'specify file name';
    
    if ~exist([DATA_FILE '.mat'], 'file'),
        urlwrite([DATA_URL DATA_FILE '.mat'], [DATA_FILE '.mat']);
        urlwrite([DATA_URL DATA_FILE '_info.mat'], [DATA_FILE '_info.mat']);
    end
    stat = set_warning_status(WARN_IDS, 'off');
    
    newFile = catfile(session.instance.Folder, 'myfile.pset');
    data = import(physioset.import.nbt('FileName', newFile), ...
        [DATA_FILE '_info.mat']);
    set_warning_status(WARN_IDS, stat);

    ok(all(size(data) == [129 59577]) && exist(newFile, 'file') > 0, name);
    
catch ME
    
    set_warning_status(WARN_IDS, 'on');
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