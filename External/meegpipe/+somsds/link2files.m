function linkNames = link2files(files, newDir)
% link2files - Create symbolic links to a set of files on a given dir
%
% See also: somsds

import mperl.file.spec.catfile;
import safefid.safefid;
import mperl.file.spec.rel2abs;

if nargin < 2 || isempty(newDir), newDir = pwd; end

if ischar(files),
    files = {files};
end

files = cellfun(@(x) rel2abs(x), files, 'UniformOutput', false);

if ~exist(newDir, 'dir'),
    mkdir(newDir);
end

linkNames = cell(size(files));

for i = 1:numel(files)
    
    [~, name, ext] = fileparts(files{i});
    
    linkNames{i} = catfile(newDir, [name ext]);
    
    
    if isunix
        if strcmp(computer, 'MACI64') && isa(files{i}, 'dir') && ...
                ~ismember(files{i}(end), {'/','\'}),
            % Take special care of symbolic links to directories
            files{i} = [files{i} filesep];
            
        end
        cmd = sprintf('ln -s %s %s', files{i}, linkNames{i});
        [res, status] = system(cmd);
    else
        % mklink does not work always so let's use a simple workaround
        % cmd = sprintf('mklink %s %s', linkNames{i}, files{i});
        fid = safefid.fopen(linkNames{i}, 'w');
        fprintf(fid, '%s', files{i});
        clear fid;
    end
    
end



end