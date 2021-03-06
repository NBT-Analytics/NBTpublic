function [status, MEh] = test1()
% TEST1 - Test dimesimeter read

import mperl.file.spec.*;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import io.edfplus.read;

% The sample data file to be used for testing
% You may have to edit some of the tests below if you change this URL
DATA_URL = ['http://kasku.org/data/meegpipe/' ...
    'pupw_0005_physiology_afternoon-sitting_day1.edf'];

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
    
    folder = session.instance.Folder;       
    file   = catfile(folder, 'sample.edf');
    urlwrite(DATA_URL, file);       
    ok(exist(file, 'file') > 0, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% read sample data
try
    
    name = 'read sample data file';   
    
    [hdr, dat, tal_cell, time] = read(file, 'Verbose', false);
 
    condition = all(size(dat) == [5 1064960]) & ...
        isfield(hdr, 'label') & numel(hdr.label) == 5 & ...
        numel(time) == 1064960 & isempty(tal_cell);
    clear dat;
    ok(condition, name);
    
    
catch ME

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