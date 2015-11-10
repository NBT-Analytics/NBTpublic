function [status, MEh] = test1()
% TEST1 - Tests basic functionality

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


%% constructor
try
    
    name = 'constructor';
    myFilter1 = filter.lpfilt('fc', .5 );
    myFilter2 = filter.hpfilt('fc', .5);
    myReport  = object(myFilter1, myFilter2);
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% print_title()
try
    
    name = 'print_title()';    
    print_title(myReport, 'A subtitle', 2);
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% generate report
try
    
    name = 'generate report';
    generate(myReport);
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% remark compilation
try
    
    name = 'remark compilation';
    evalc(['report.remark(''' session.instance.Folder ''')']);
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Cleanup
try
    
    name = 'cleanup';
    clear myReport myParentReport;
    rmdir(session.instance.Folder, 's');
    session.clear_subsession();
    ok(true, name);
    
catch ME
    ok(ME, name);
end


%% Testing summary
status = test.simple.finalize();


end

