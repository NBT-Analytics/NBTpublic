function obj = initialize(obj)


import misc.get_username;
import misc.get_hostname;
import misc.get_matlabver;
import report.object.object;
import mperl.file.spec.abs2rel;
import datahash.DataHash;

% Cleanup the destination directory
rPath = def_rootpath(obj);
if exist(rPath, 'dir')
    if ispc,
        rmdir(rPath, 's'); 
    else
        % No idea why MATLAB's rmdir sometimes fails under Linux
        system(['rm -rf ' rPath]);
    end    
end


obj = initialize@report.generic.generic(obj);

gitMaster = meegpipe.version;
if numel(gitMaster) > 10,
    gitMaster = gitMaster(2:end);
end

print_paragraph(obj, ...
    ['Data processing ran by user _%s_, at host %s (%s), on %s, ' ...
    'using [meegpipe][meegpipe]''s snapshot [%s][%s] on MATLAB %s.'], ...
    get_username, get_hostname, computer, ...
    datestr(now, 'dd-mm-yy HH:MM:SS'), ...
    [gitMaster '...'], gitMaster, get_matlabver);

target = 'https://github.com/meegpipe/meegpipe';
name   = 'meegpipe';
print_link(obj, target, name);

target = sprintf(...
    'http://github.com/meegpipe/meegpipe/commit/%s', gitMaster);
name   = gitMaster;
print_link(obj, target, name);

if isempty(get_parent(obj)),
    %% Specific to top-level nodes
    
    savedNode  = abs2rel(saved_node(obj.Node_), get_save_dir(obj.Node_));
    savedInput = abs2rel(saved_input(obj.Node_), get_save_dir(obj.Node_));
    
    print_paragraph(obj, ...
        'To reproduce this analysis run:');
    
    code = {...
        'clear all;', ...
        'currDir = pwd;' ...
        };

    % Fieltrip and EEGLAB path
    depDirs = meegpipe.get_deps_dirs;
    addpathCmd = cell(1,numel(depDirs));
    for i = 1:numel(depDirs)
       addpathCmd{i} = sprintf('addpath(genpath(''%s''));', depDirs{i});       
    end
    
    code = [code ...
        {...       
        sprintf(['urlwrite(''https://github.com/meegpipe/meegpipe/archive/' ...
        '%s.zip'', ''meegpipe.zip'');'], gitMaster), ...
        'unzip(''meegpipe.zip'');', ...
        'restoredefaultpath;'}, ...
        addpathCmd, ...
        { ...
        sprintf('addpath(genpath([pwd filesep ''meegpipe-%s'']));', gitMaster), ...
        sprintf('cd(''%s'');', get_save_dir(obj.Node_)), ...
        sprintf('node = load(''%s'', ''obj'');', savedNode), ...
        sprintf('input = load(''%s'', ''data'');', savedInput), ...
        'cd(currDir)', ...
        'meegpipe.initialize;', ...
        'output = run(node.obj, input.data);' ...
        } ...
        ];
    
    print_code(obj, code{:});
    
    print_paragraph(obj, ...
        ['__Note:__ You may need to change the absolute path above if ' ...
        'this report has been moved from its original location']);
    
end

% Print sub-report with the node properties

subReport = object(obj.Node_, 'Title', 'Node properties');
subReport = childof(subReport, obj);

generate(subReport);

print_paragraph(obj, whatfor(obj.Node_));

end