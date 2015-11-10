function [pValue, refs] = struct2str(origRepObj, pValue, varargin)

import misc.process_arguments;
import mperl.file.spec.catfile;
import xml.struct2xml;
import misc.unique_filename;
import safefid.safefid;

opt.argname  = '';
opt.propname = '';
opt.id       = '';
[~, opt] = process_arguments(opt, varargin);

[~, name] = fileparts(get_filename(origRepObj));
path = get_rootpath(origRepObj);

if ~isempty(opt.id)
    id = opt.id;
elseif ~isempty(opt.argname),
    id = opt.argname;
elseif ~isempty(opt.propname),
    id = opt.propname;
else
    id = 'noid';
end

refs = cell(1,2);

% Write to xml file and link
refs{1,1} = sprintf('pValue-%s',id);
refs{1,2} = [name '_pval-' id '.xml'];
fileName  = unique_filename(catfile(path, refs{1,2}));
[~, name] = fileparts(fileName);
refs{1,1} = name;
refs{1,2} = [name '.xml'];

% In Windows, we may need to use extended paths. See:
% http://msdn.microsoft.com/en-us/library/aa365247%28VS.85%29.aspx#maxpath
if ispc && numel(fileName) > 255,
    fileName = ['\\?\' fileName];
end

% Write struct contents to .xml file
fidTmp = safefid(fileName, 'w');
fprintf(fidTmp, '%s', struct2xml(pValue));
tidyObj = mperl.xml.tidy.tidy(catfile(path, refs{1,2}));
make_tidy(tidyObj);

% String pValue and corresp. reference
text   = num2str(size(pValue));
text   = regexprep(text, '\s+', 'x');
pValue = sprintf('[ [%s struct] ][%s]', text, refs{1,1});


end