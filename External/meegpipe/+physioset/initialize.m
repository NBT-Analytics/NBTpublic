function initialize(cfg)

import mperl.config.inifiles.inifile;
import mperl.file.spec.*;
import mperl.cwd.abs_path;
import physioset.get_config;
import misc.existing_dir;
import mperl.join;
import mperl.split;
import physioset.root_path;
import mjava.hash;

if nargin < 1 || isempty(cfg),
    cfg = get_config();
end

% Root dirs of all dependencies
depRoot = hash;

verboseLabel = '(physioset) ';

fprintf(['\n\n' verboseLabel 'Initializing...\n\n']);

%% Add dependencies to the path
depList = parameters(cfg, 'thirdparty');
if ischar(depList) && ~isempty(depList), depList = {depList}; end

unmetDeps = {};
for i = 1:numel(depList)
    
    dirList = val(cfg, 'thirdparty', depList{i}, true);
    dirList = cellfun(@(x) rel2abs(x, root_path), dirList, ...
        'UniformOutput', false);
    thisDir = existing_dir(dirList);
    if isempty(thisDir),
        unmetDeps = [unmetDeps;depList(i)]; %#ok<AGROW>
    else
        absDir = rel2abs(thisDir);
        depRoot(depList{i}) = strrep(absDir, '\', '/');
        fprintf([verboseLabel 'Found %s: %s\n\n'], upper(depList{i}), absDir);
        addpath(genpath(absDir));
    end
    
end

%% Remove some problematic folders from the path. Damn MATLAB!
problematic = {...
    [depRoot('fieldtrip') '/compat'] ...
    [depRoot('fieldtrip') '/external/dss'] ...
    [depRoot('eeglab') '/functions/octavefunc'] ...
    };

if isunix, sep = ':'; else sep = ';'; end
pathList = split(sep, path);
pathList2 = cellfun(@(x) strrep(x, '\', '/'), pathList, ...
    'UniformOutput', false);

fprintf([verboseLabel 'Removing problematic dirs from path:\n\n']);
fprintf(join('\n', problematic));
fprintf('\n\n');

for i = 1:numel(problematic)
    
    isProblematic = cellfun(@(x) ~isempty(strfind(x, problematic{i})), pathList2);
    
    cellfun(@(x) rmpath(x), pathList(isProblematic));
    
end

if ~isempty(unmetDeps),
    fprintf([verboseLabel 'The following dependencies were not found:\n\n']);
    fprintf(join('\n', unmetDeps));
    fprintf('\n\n');
end

fprintf([verboseLabel 'Done with initialization\n\n']);


end