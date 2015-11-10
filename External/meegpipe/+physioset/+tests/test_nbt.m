function [status, MEh] = test_nbt()
% TEST_NBT - Test conversion to/from NBT format


import test.simple.*;
import mperl.file.spec.*;
import physioset.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;

MEh     = [];

% The sample data file to be used for testing
DATA_FILE = 'NBT.S0021.090205.EOR1';
DATA_URL = 'http://kasku.org/data/meegpipe/';

% The warnings to ignore when calling physioset-generating methods
WARN_IDS = { 'sensors:InvalidLabel', 'sensors:MissingPhysDim' };

initialize(3);

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
    MEh = [MEh ME];
    
end

%% build physioset from NBT structure
try
    
    name = 'build physioset from NBT structure';
    
    if ~exist([DATA_FILE '.mat'], 'file') || ...
            ~exist([DATA_FILE '.mat'], 'file')
        url = [DATA_URL DATA_FILE '.zip'];
        unzip(url, pwd);
    end
    load([DATA_FILE '_info.mat']);
    load([DATA_FILE '.mat']);
    stat = misc.set_warning_status(WARN_IDS, 'off');
    data = physioset.physioset.from_nbt(RawSignalInfo, RawSignal);
    misc.set_warning_status(WARN_IDS, stat);
    
    ok( ...
        size(data, 1) == 129 && ...
        size(data, 2) == 59577 && ...
        numel(get_event(data)) == 1 && ...
        isa(get_event(data), 'physioset.event.std.discontinuity') && ...
        ~isempty(get_meta(data, 'nbt')), ...
        ...
        name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% Cleanup
try
    
    name = 'cleanup';
    clear data ans;
    rmdir(session.instance.Folder, 's');
    session.clear_subsession();
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Testing summary
status = finalize();

end

