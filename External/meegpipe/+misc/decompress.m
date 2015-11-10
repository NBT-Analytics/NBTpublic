function [status, filename] = decompress(filename, varargin)

import misc.process_arguments;
import mperl.file.spec.*;

thisLabel = '(decompress) ';

opt.verbose = true;
[~, opt] = process_arguments(opt, varargin);

status = true;

[path, name, ext] = fileparts(filename);

switch lower(ext)    
    case '.bz2',
        [status, ~] = system('bunzip2 -h');
        if status,            
            warning('misc:decompress:MissingBZip2', ...
                'The bzip2 program is required to uncompress file %s', filename);
            return;
        end
        cmd = sprintf('bunzip2 --keep %s', filename);        
        if opt.verbose,
            fprintf('\n(misc:decompress) Decompressing %s...', filename);
        end
        filename = catfile(path, name);
        status = system(cmd);        
        if opt.verbose,
            fprintf('\n\n');
        end
        
    case '.7z',
        if isunix,
            cmd = 'p7zip';
        else
            cmd = '7z';
        end
        [status, ~] = system(cmd);
        if status,
            warning('misc:decompress:Missing7Zip', ...
                'The 7zip program is required to uncompress file %s', filename);
            return;
        end
        filename = abs2rel(filename);
        oDir = fileparts(filename);
        if ~isempty(oDir),
            cmdCall = sprintf('%s e -y -o%s %s', cmd, oDir, filename);
            filename = catfile(oDir, name);
        else
            cmdCall = sprintf('%s e -y %s', cmd, filename);
            filename = name;
        end
        if opt.verbose,
            fprintf('\n(misc:decompress) Decompressing %s...', filename);
        end
        status = system(cmdCall);
        if opt.verbose,
            fprintf('\n\n');
        end
    case '.gz'
        [path, name] = fileparts(filename);
        if opt.verbose,            
            fprintf([thisLabel 'Uncompressing %s ...'], name);
        end
        gunzip(filename);
        if opt.verbose,           
            fprintf('[done]\n\n');
        end
        filename = catfile(path, name);
        status = false;
    case '.zip'
         [path, name] = fileparts(filename);
        if opt.verbose,            
            fprintf([thisLabel 'Uncompressing %s ...'], name);
        end
        unzip(filename);
        if opt.verbose,           
            fprintf('[done]\n\n');
        end
        filename = catfile(path, name);
        status = false;
    otherwise
        % Do nothing
end











end