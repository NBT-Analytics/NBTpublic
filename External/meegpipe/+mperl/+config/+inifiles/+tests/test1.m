function [status, MEh] = test1()
% TEST1 - Tests class methods

import mperl.config.inifiles.inifile;
import mperl.file.spec.catfile;
import mperl.file.spec.catdir;
import mperl.config.inifiles.root_path;
import pset.session;
import test.simple.*;
import datahash.DataHash;

FILE        = catfile(root_path, 'somsds.ini');

MEh = [];

initialize(26);

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

%% check val()
try
    
    name = 'method val()';
    cfg     = inifile(FILE_COPY);
    param1  = val(cfg, 'somsds', 'root_path');
    ok(strcmp(param1, '/data1'), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
end

%% check setval()
try
    
    name = 'method setval()';
    thisStatus = setval(cfg, 'somsds', 'root_path', '100');
    param1 = val(cfg, 'somsds', 'root_path');
    ok(thisStatus && strcmp(param1, '100'), name);
  
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% check setval() with spaces
try
    
    name = 'method setval() with spaces';
    thisStatus = setval(cfg, 'somsds', 'root_path', '100 y pico');
    param1 = val(cfg, 'somsds', 'root_path');
    ok(thisStatus && strcmp(param1, '100 y pico'), name);
  
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% setval()
try
    
    name = 'method setval()';
    ok(~setval(cfg, 'somsds', 'doesnotexist', '100'), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% setval()
try
    
    name = 'method setval()';
    ok(~setval(cfg, 'nope', 'doesnotexist', '100'), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% newval()
try
    
    name = 'method newval()';
    thisStatus = newval(cfg, 'somsds', 'root_path', '100');
    param = val(cfg, 'somsds', 'root_path');
    ok(thisStatus && strcmp(param, '100'), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% newval()
try
    
    name = 'method newval()';
    thisStatus = newval(cfg, 'bad', 'doesnotexist', '100');
    param = val(cfg, 'bad', 'doesnotexist');
    ok(thisStatus && strcmp(param, '100'), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% delval()
try
    
    name = 'method delval()';
    thisStatus = delval(cfg, 'bad', 'doesnotexist');
    success = thisStatus && isempty(val(cfg, 'bad', 'doesnotexist'));    
    ok(success, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% delete_section()
try
    
    name = 'method delete_section()';
    thisStatus = delete_section(cfg, 'bad');
    success = thisStatus && ~section_exists(cfg, 'bad');
    ok(success, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% sections()
try
    
    name = 'method sections()';
    sectionNames = sections(cfg);
    success =  (numel(sectionNames) == 53 && all(ismember(...
        {'somsds', 'dependencies', 'modality eeg'}, sectionNames)));
    ok(success, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% section_exists()
try
    
    name = 'method section_exists()';
    ok(section_exists(cfg, 'modality meg'), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% check push()
try
    
    name = 'method push()';    
    ok(push(cfg, 'somsds', 'files_csv', 'seconddd.kk'), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% val() for multi-valued parameters
try
    
    name = 'method val() for multi-valued params';
    value = val(cfg, 'somsds', 'files_csv', true);
    success =  (numel(value) == 2 && ...
        all(ismember({'files.csv', 'seconddd.kk'}, value)));
    ok(success, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% newval()
try
    
    name = 'method newval() for multi-value params';
    
    success = newval(cfg, 'somsds', 'files_csv', 'val1', 'val2') && ...
        all(ismember({'val1', 'val2'}, ...
        val(cfg, 'somsds', 'files_csv', true)));    
    ok(success, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% exists()
try
    
    name = 'method exists()';
    ok(exists(cfg, 'somsds', 'files_csv'), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% section_exists()
try
    
    name = 'method section_exists()';
    ok(~section_exists(cfg, 'shouldnotexist'), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% add_section
try
    
    name = 'method add_section()';    
    ok(add_section(cfg, 'shouldnotexist'), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% section_exists()
try
    
    name = 'method section_exists()';
    ok(section_exists(cfg, 'shouldnotexist'), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% group_members()
try
    
    name = 'group_members()';    
    groupMembers = group_members(cfg, 'device');
    success = (numel(groupMembers) == 4 &&...
        ismember('device neuromag306', groupMembers));
    ok(success, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% groups()
try
    
    name = 'method groups()';    
    groupNames = groups(cfg);
    success = (numel(groupNames) == 4 && ismember('modality', groupNames));
    ok(success, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% set_file_name()
try
    
    name = 'method set_file_name()';    
    warning('off', 'inifile:CreatedIniFile');
    tmpIniFile =  catfile(PATH, 'example.ini');
    cfg = inifile(tmpIniFile);
    warning('on', 'inifile:CreatedIniFile');
    cfg = set_file_name(cfg, FILE_COPY);    
    success = strcmpi(val(cfg, 'somsds', 'rec_folder'), 'recordings');
    ok(success, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% parameters()
try
    
    name = 'method parameters()';
    paramNames = parameters(cfg, 'somsds');
    success = (numel(paramNames) == 11 && ismember('separator', paramNames));
    ok(success, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% get_section_comment()
try
    
    name = 'method get_section_comment()';
    set_section_comment(cfg, 'somsds', 'First Comment', 'Second comment');
    comments = get_section_comment(cfg, 'somsds', true);
    success = (iscell(comments) && numel(comments) == 2 && ...
        ismember('# First Comment', comments));
    ok(success, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Cleanup
try
    
    name = 'cleanup';
    clear fid cfg;
    rmdir(PATH, 's');
    pause(1);
    ok(true, name);
    
catch ME
    ok(ME, name);
end


%% tests summary
status = finalize();

end
