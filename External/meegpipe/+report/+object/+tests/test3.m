function [status, MEh] = test3()
% TEST3 - Tests reporting on reportable objects

import mperl.file.spec.*;
import report.object.*;
import test.simple.ok;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;

MEh     = [];

test.simple.initialize(6);

%% Create a test dir
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



%% construct a sample reportable object
try
    
    name = 'construct a sample reportable object';
    myChopper = chopper.ged('PreFilter', filter.lpfilt('fc', .5));
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% constructor
try
    
    name = 'constructor';
    myReport  = object(myChopper);
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% set_title/get_title
try
    
    name = 'set_title/get_title';    
    set_title(myReport, name);
    ok(strcmp(get_title(myReport), name), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end
%% generate report
try
    
    name = 'generate report on reportable object';
    generate(myReport);
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% Cleanup
try
    
    name = 'cleanup';
    clear myReport myParentReport data ans;
    rmdir(session.instance.Folder, 's');
    session.clear_subsession();
    ok(true, name);
    
catch ME
    ok(ME, name);
end

%% Testing summary
status = test.simple.finalize();

end
