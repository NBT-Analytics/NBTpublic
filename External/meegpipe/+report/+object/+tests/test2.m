function [status, MEh] = test2()
% TEST2 - Tests physioset reporting capabilities

import mperl.file.spec.*;
import report.object.*;
import test.simple.ok;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;

MEh     = [];

test.simple.initialize(11);

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

%% Create sample physioset
try
    
    name = 'create sample physioset';
    data = import(physioset.import.matrix, randn(10,10000));
    set_method_config(data, 'fprintf', 'SaveBinary', false);
    set_bad_channel(data, 3:5);
    set_bad_sample(data, 500:2000);
    set_name(data, 'rand dataset');
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% report constructor
try
    
    name = 'report constructor';
    myReport = object(data);    
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

%% generate()
try
    
    name = 'generate()';
    generate(myReport);
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% set_level/get_level
try
    
    name = 'set_level/get_level';    
    set_level(myReport, 2);
    generate(myReport);
    ok(get_level(myReport) == 2, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% print_title()
try
    
    name = 'print_title()';    
    count = print_title(myReport, 'Third level subtitle', 3);
    ok(count == 26, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% Generate a new report, now with the binary data
try
    
    name = 'initialize report with binary data';
    set_method_config(data, 'fprintf', ...
        'ParseDisp', false, 'SaveBinary', true);
    myReport = object(data);
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% generate report
try
    
    name = 'generate report with binary data';
    generate(myReport);
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end



%% And finally a report with both summary info and binary data

try
    
    name = 'both binary data and summary info';
    set_method_config(data, 'fprintf', ...
        'ParseDisp', true, 'SaveBinary', true);
    myReport = object(data);
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
