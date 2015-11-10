function folder = save(obj, folder)

import pset.globals;

if nargin < 2 || isempty(folder),
    folder = obj.Folder;
end

if ~exist(folder, 'dir'),
    mkdir(folder);
    warning('save:folderCreated', 'Folder %s has been created', folder);
end

% Store all variables of class pset.pset
vars = evalin('base', 'whos');
headerExt = globals.evaluate.HdrFileExt;
for i = 1:numel(vars)
    obj = evalin('base', vars(i).name);
    if isa(obj, 'pset.pset'),
        obj.Temporary = false;
        eval([vars(i).name '=obj;']);
        [path, name] = fileparts(obj.DataFile);
        save([path filesep name headerExt], vars(i).name);
    elseif iscell(obj)
        for j = 1:numel(obj)
            if isa(obj{j}, 'pset.pset'),
                obj{j}.Temporary = false;
                eval([vars(i).name '{' num2str(j) '}.Temporary=false;']);
                eval([vars(i).name '_' num2str(j) '=obj{j};']);
                [path, name] = fileparts(obj{j}.DataFile);
                save([path filesep name headerExt], ...
                    [vars(i).name '_' num2str(j)]);
            end
        end
        
    end
end






end