function [pValue, refs] = num2str(origRepObj, pValue, varargin)

import misc.process_arguments;
import mperl.file.spec.catdir;

MAX_MSIZE = 100000000;

opt.argname = '';
opt.propname = '';
[~, opt] = process_arguments(opt, varargin);

[~, name] = fileparts(get_filename(origRepObj));
path      = get_rootpath(origRepObj);

if ~isempty(opt.argname),
    id = pt.argname;
elseif ~isempty(opt.propname),
    id = opt.propname;
else
    id = '';
end    

refs = cell(1,2);

if numel(pValue) < 10,
    pValue = misc.num2str(pValue);
else
    text = num2str(size(pValue));
    text = ['[' regexprep(text, '\s+', 'x') ' ' ...
        class(pValue) ']'];
    if ndims(pValue) == 2 && numel(pValue) < MAX_MSIZE
        % Write to a disk file
        refs{1,1} = ['pValue-' id];
        refs{1,2} = catdir(path, [name '_pval-' id '.csv']);                       
        dlmwrite(refs{1,2}, pValue);
        pValue = sprintf('[%s][%s]', text, refs{1,1});
    else
        pValue = text;
    end
end


end