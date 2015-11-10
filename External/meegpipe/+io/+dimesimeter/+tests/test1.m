function [status, MEh] = test1()
% TEST1 - Test dimesimeter read

import mperl.file.spec.*;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import io.dimesimeter.read;

% The sample data file to be used for testing
% You may have to edit some of the tests below if you change this URL
DATA_URL = {['http://kasku.org/data/meegpipe/' ...
    'pupw_0001_ambient-light_coat_ambulatory.txt'], ...
    ['http://kasku.org/data/meegpipe/' ...
    'pupw_0001_ambient-light_coat_ambulatory_header.txt']};

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
    fileHeader = catfile(folder, 'sample_header.txt');
    fileRaw = catfile(folder, 'sample.txt');
    urlwrite(DATA_URL{1}, fileRaw);   
    urlwrite(DATA_URL{2}, fileHeader);    
    ok(exist(fileRaw, 'file') > 0 && exist(fileHeader, 'file') > 0, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% read sample data
try
    
    name = 'read sample data file';   
    
    [data, time, hdr] = read(fileHeader);
 
    condition = all(size(data) == [8914 7]) & ...
        isfield(hdr, 'label') & numel(hdr.label) == 7 & numel(time) == 8914;
    clear data;
    ok(condition, name);
    
    
catch ME
    
    warning('on', 'sensors:MissingPhysDim');
    warning('on', 'sensors:InvalidLabel');
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