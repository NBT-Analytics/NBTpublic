function str = inkscape_binary()
% INKSCAPE_BINARY - Full path to Inkscape's binary

import mperl.config.inifiles.inifile;
import mperl.file.spec.catfile;
import mperl.file.spec.rel2abs;
import mperl.cwd.abs_path;
import inkscape.root_path;
import inkscape.dir;

str = 'inkscape';

path = meegpipe.get_config('inkscape', 'path', true);

for i = 1:numel(path)
    
    thisPath = abs_path(rel2abs(path{i}, root_path));
    if exist(thisPath, 'dir'),
        
        if ispc,
            regex = 'inkscape\.exe$';
        else
            regex = 'inkscape$';
        end
        fileList = dir(thisPath, regex);
        
        if numel(fileList) > 1,
            error('Multiple matches for inkscape binary');
        elseif ~isempty(fileList),
            str = catfile(thisPath, fileList{1});
            return;
        end
        
    end
    
end

end