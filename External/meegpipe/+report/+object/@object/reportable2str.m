function [pValue, refs] = reportable2str(origRepObj, pValue, varargin)

import misc.process_arguments;
import report.object.object;

opt.ParentArgName = '';
opt.ParentPropName = '';
[~, opt] = process_arguments(opt, varargin);

refs = cell(1,2);

%% Generate sub-report
repObj = object(pValue);
set_rootpath(repObj, get_rootpath(origRepObj));


title = class(pValue);

% The class name can be very long and ugly
title = regexprep(title, '^.+\.([^\.]+)$', '$1');

if ~isempty(opt.ParentArgName),
    title = [title ' from argument ' opt.ParentArgName];
elseif ~isempty(opt.ParentPropName),
    title = [title ' from property ' opt.ParentPropName];
end
set_title(repObj, title);

childof(repObj, origRepObj);

initialize(repObj);

generate(repObj);

%% Link to sub-report
text = num2str(size(pValue));
text = ['[' regexprep(text, '\s+', 'x') ' ' ...
    class(pValue) ']'];

[~, refs{1,1} ext]  = fileparts(get_filename(repObj));
refs{1,2}       = [refs{1,1} ext];
refs{1,2}       = sprintf('[[Ref: %s]]', refs{1,2});
pValue          = sprintf('[%s][%s]', text, refs{1,1});


end