function [status, MEh] = test_move()
% TEST_MOVE - Test method move()

import test.simple.*;
import mperl.file.spec.*;
import physioset.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import meegpipe.node.*;

MEh     = [];

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

%% move a sample file
try
    
    name = 'move a sample file';
    data = import(physioset.import.matrix, rand(5, 100));
    dataOrig = data(:,:);    
    origFile = get_datafile(data);   
    [fPath, fName, fExt] = fileparts(origFile);
    data2 = move(data, 'PostFix', '_moved');
    
    ok(...
        max(max(abs(data(:,:) - dataOrig))) < eps & ...
        strcmp(get_datafile(data2), get_datafile(data)) & ...
        strcmp(get_datafile(data2), catfile(fPath, [fName '_moved' fExt])), name);
    
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


