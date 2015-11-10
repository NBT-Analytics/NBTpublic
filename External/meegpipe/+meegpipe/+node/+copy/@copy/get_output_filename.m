function outFileName = get_output_filename(obj, inFileName)

import mperl.file.spec.catfile;

if ~isempty(get_config(obj, 'Filename')),
    
    [path, name, ext] = fileparts(get_config(obj, 'Filename'));
    
else
    
    [~, name, ext] = fileparts(get_datafile(inFileName));
    
    path = get_full_dir(obj, inFileName);
    
    if ~isempty(get_config(obj, 'Path')),
        path = get_config(obj, 'Path');
    end

end

prefix  = get_config(obj, 'PreFix');
postfix = get_config(obj, 'PostFix');

outFileName = catfile(path, [prefix name postfix ext]);


end