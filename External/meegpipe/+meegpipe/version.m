function id = version()

import mperl.file.spec.rel2abs;
import safefid.safefid;
import mperl.file.spec.catfile;

FILE_NAME = '.git/refs/heads/master';

dirName = regexprep(meegpipe.root_path, '.\+meegpipe$', '');
fileName = catfile(dirName, FILE_NAME);
%currDir = pwd;
try
    if exist(fileName, 'file')
        fid = safefid.fopen(fileName, 'r');
        id = fid.fgetl;
    else
        % If the user followed the installation instructions on the web,
        % then his meegpipe installation dir is named
        % meegpipe-[version]
       
        match = regexp(dirName, 'meegpipe-(?<id>.+)$', 'names');
        if isempty(match)
            warning('meegpipe:version:Unknown', ...
                ['Could not figure out meegpipe version. You may have ' ... 
                'problems reproducing your results in the future. ' ...
                'To solve this issue, follow exactly the installation ' ...
                'instructions at http://germangh.com/meegpipe']);
            id = 'unknown';
        else
            id = match.id;
        end        
    end
catch ME
    rethrow(ME);
end

id = ['v' id];

end