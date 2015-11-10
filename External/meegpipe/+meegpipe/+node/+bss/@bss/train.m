function obj = train(obj, trainInput, varargin)

import mperl.file.spec.catfile;
import mperl.config.inifiles.inifile;

if ~iscell(trainInput),
    trainInput = {trainInput};
end

verbose          = is_verbose(obj);
verboseLabel     = get_verbose_label(obj);

isStr = cellfun(@(x) ischar(x), trainInput);
if ~all(isStr),
    error('A cell array of file names is expected as second input argument');
end

% Get all the training samples in one table
X = [];
y = [];

for i = 1:numel(trainInput)
    if verbose,
        fprintf([verboseLabel 'Reading training data for %s ...'], ...
            trainInput{i});
    end
    
    nodeDir = get_full_dir(obj, trainInput{i});
    
    % Read the feature values
    featFile = catfile(nodeDir, 'criterion_training.csv');
    featVal  = dlmread(featFile, ',');
 
    % Read the selected components
    cfgFile = catfile(nodeDir, [get_name(obj) '.ini']);
    cfg = inifile(cfgFile);
    sel = val(cfg, 'bss', 'selection', true);
    
    selected = false(size(featVal, 1), 1);
    if ~isempty(sel),
        sel = cellfun(@(x) eval(x), sel);
        selected(sel) = true;
    end
    if ~isempty(sel) && all(isnan(sel)), 
        if verbose, fprintf('[skipped]\n\n'); end
        continue;
    end
    y = [y; selected]; %#ok<AGROW>    
    
    X = [X; featVal]; %#ok<AGROW>
    
    if verbose, fprintf('[done]\n\n'); end
end


if verbose,
    fprintf([verboseLabel 'Training linear discriminant ...']);
end
ldModel = ClassificationDiscriminant.fit(X, y);

set_training_model(obj, ldModel);

if verbose,
    fprintf('[done]\n\n');
end

end