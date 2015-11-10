function [pValue, refs] = fhandle2str(origRepObj, pValue, varargin)
% FHANDLE2STR - Convert file handle to 

import misc.process_arguments;
import mperl.file.spec.catfile;

opt.argname = '';
opt.propname = '';
opt.id = '';

[~, opt] = process_arguments(opt, varargin);

[~, name] = fileparts(get_filename(origRepObj));
path      = get_rootpath(origRepObj);

if ~isempty(opt.id),
    id = opt.id;
elseif ~isempty(opt.argname),
    id = opt.argname;
elseif ~isempty(opt.propname),
    id = opt.propname;
else
    id = 'noid';
end    

refs = cell(1,2);

% Write to a text file and create a link to it
refs{1,1}   = sprintf('pValue-%s', id);
refs{1,2}   = [name '_pval-' id '.txt'];
newFile     = catfile(path, refs{1,2});
fidTmp      = fopen(newFile, 'w');

try
    fprintf(fidTmp, '%s', char(pValue));
    pValue = sprintf('[ [function_handle] ][%s]', refs{1,1});
    fclose(fidTmp);
catch ME
    fclose(fidTmp);
    rethrow(ME);
end

end