function y = abs_path(path)

import mperl.perl;
import mperl.cwd.*;
import mperl.file.spec.catfile;

if nargin < 1 || isempty(path),
    y = '';
    return;
end

if iscell(path),
    y = cell(size(path));
    for i = 1:numel(y)
        if isempty(path{i}), 
            y{i} = cd;
            continue; 
        end
        
        y{i} = abs_path(path{i});
        
    end
else
    if ~exist(path, 'dir') & ~exist(path, 'file'),
        y = path;
    else
        plFile = catfile(root_path, 'abs_path.pl');
        y = perl(plFile, path);
    end
    
    y = strrep(y, '/', filesep);
end

end