function myPipe = bss_supervised(varargin)
% BSS_SUPERVISED - Fully supervised BSS-based artifact rejection

import misc.process_arguments;
import misc.split_arguments;

opt.MinCard     = @(lambda) min(20, max(2, 0.25*numel(lambda)));
opt.RetainedVar = 99.9999;
opt.MaxCard     = 35;
opt.BSS         = {spt.bss.multicombi};
% What should we do with the bad data epochs when exporting to EEGLAB?
% reject=concatenate all good epochs
% flatten=set bad epochs to zero
% donothing=mark bad epochs with boundary events only
opt.BadDataPolicy = 'reject';

[thisArgs, varargin] = split_arguments(opt, varargin);
[~, opt] = process_arguments(opt, thisArgs);

mySel = pset.selector.cascade(...
    pset.selector.sensor_class('Class', 'EEG'), pset.selector.good_data);
myPCA = spt.pca(...
    'RetainedVar',  opt.RetainedVar, ...
    'MinCard',      opt.MinCard, ...
    'MaxCard',      35);

myFeat = spt.feature.bp_var;

myCrit = spt.criterion.threshold(...
    'MaxCard', 0, ...  % Do not reject anything automatically
    'Feature', myFeat ...
    );

if ~iscell(opt.BSS),
    opt.BSS = {opt.BSS};
end

nodeList = cell(1, numel(opt.BSS));
for i = 1:numel(opt.BSS)
    
    % A multicombi node
    myNode = meegpipe.node.bss.new(...
        'BSS',          opt.BSS{i}, ...
        'Criterion',    myCrit, ...
        'DataSelector', mySel, ...
        'PCA',          myPCA, ...
        'Name',         get_name(opt.BSS{i}), ...
        varargin{:});
    
    nodeList{i} = myNode;
end

myPipe = meegpipe.node.pipeline.new(...
    'NodeList', nodeList, ...
    'Name',     'bss-supervised');


end