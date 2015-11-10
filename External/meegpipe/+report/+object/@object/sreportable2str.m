function [pValue, refs] = sreportable2str(origRepObj, pValue, varargin)

import misc.process_arguments;

opt.ParentPropName = '';
opt.ParentArgName  = '';
[~, opt] = process_arguments(opt, varargin);

refs = cell(1,2);

%% Generate a sub-report 
repObj = report.object(...
    'Parent',           origRepObj.FileName, ...
    'ParentArgName',    opt.ParentArgName, ...
    'ParentPropName',   opt.ParentPropName);
initialize(repObj, pValue);
generate(repObj, pValue);


%% Link to the sub-report
text = num2str(size(pValue));
text = ['[' regexprep(text, '\s+', 'x') ' ' ...
    class(pValue) ']'];

[~, refs{1,1} ext]  = fileparts(repObj.FileName);
refs{1,2}       = [refs{1,1} ext];
refs{1,2}       = sprintf('[[Ref: %s]]', refs{1,2});
pValue          = sprintf('[%s][%s]', text, refs{1,1});

end