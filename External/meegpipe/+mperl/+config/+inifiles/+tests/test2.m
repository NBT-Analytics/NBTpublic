function [status, MEh] = test2()
% TEST2 - Tests storage and retrieval of complex data structures


import mperl.config.inifiles.inifile;
import mperl.file.spec.catfile;
import mperl.file.spec.catdir;
import mperl.config.inifiles.root_path;
import test.simple.*;
import datahash.DataHash;
import pset.session;
import misc.rmdir;

FILE        = catfile(root_path, 'somsds.ini');

MEh = [];

initialize(14);

%% Create a test dir
try
    name = 'create test dir';
    warning('off', 'session:NewSession');
    PATH = catdir(session.instance.Folder, DataHash(randn(1,100)));
    mkdir(PATH);
    warning('on', 'session:NewSession');   
    FILE_COPY   = catfile(PATH, 'somsds_copy.ini');
    
catch ME
    ok(ME, name);
    status = finalize();
    return;
end
ok(true, name);

%% Create sample .ini file
try
    
    name = 'create sample .ini file';
    success = copyfile(FILE, FILE_COPY);
    
    ok(success, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% constructor
try
    
    name = 'constructor';
    cfg = inifile(FILE_COPY);
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% set param to a struct value
try
    
    name = 'set param to struct value';
    str = struct('field1', 1, 'field2', 'value2');
    ok(setval(cfg, 'somsds', 'root_path', str), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% recover the struct value
try
    
    name = 'retrieve struct value';
    str = struct('field1', 1, 'field2', 'value2');
    value = eval(val(cfg, 'somsds', 'root_path'));
    ok(strcmp(DataHash(value), DataHash(str)), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% set a parameter to a cell array
try
    
    name = 'store cell array';    
    cArray = {str, 'string', 5, 1:4; [], [], eye(3),[]};
    ok(setval(cfg, 'somsds', 'root_path', cArray), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% recover cell array
try
    
    name = 'retrieve cell array';
    value = eval(val(cfg, 'somsds', 'root_path'));
    cArray = {str, 'string', 5, 1:4; [], [], eye(3),[]};
    ok(strcmp(DataHash(value), DataHash(cArray)), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% numeric matrix
try
    
    name = 'store numeric matrix';
    matrix = randn(4,10);
    ok(setval(cfg, 'somsds', 'root_path', matrix), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% recover the numeric matrix
try
    
    name = 'retrieve numeric matrix';
    value = eval(val(cfg, 'somsds', 'root_path'));
    ok(all(abs(value(:)-matrix(:)) < 1e-3), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Add a section that has spaces
try
    
    name = 'retrieve numeric matrix';
    
    secName = 'window 1';
    
    add_section(cfg, secName);
    
    ok(section_exists(cfg, secName), name);
    
    catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% numeric matrix in section with spaces
try
    
    name = 'numeric matrix in section with spaces';
    matrix = randn(4,10);
    ok(newval(cfg, 'window 1', 'param2', matrix), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% recover the numeric matrix
try
    
    name = 'retrieve numeric matrix';
    value = eval(val(cfg, 'window 1', 'param2'));
    ok(all(abs(value(:)-matrix(:)) < 1e-3), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% Add an array as multiple values

try
    
    name = 'numeric array as multiple values';
    
    secName = 'window 2';
    
    add_section(cfg, secName);
    
    newval(cfg, secName, 'myparam');
    
    setval(cfg, secName, 'myparam', 1:10);
    
    ok(section_exists(cfg, secName), name);
    
    catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% Cleanup
try
    name = 'cleanup';
    clear fid cfg;
    rmdir(PATH, 's');
    ok(true, name);
catch ME
    ok(ME, name);
end


%% tests summary
status = finalize();
