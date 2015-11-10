function obj = topo_generic(varargin)
% TOPO_GENERIC - Identify EOG components using topography

import misc.process_arguments;
import misc.split_arguments;
import misc.split_arguments;
import pset.selector.sensor_class;
import pset.selector.good_data;
import pset.selector.cascade;

%% Process input arguments
opt.MinCard         = 2;
opt.MaxCard         = @(d) min(10, ceil(0.25*length(d)));
opt.Max             = {...
    @(feat) median(feat), ... % Relaxed threshold for symmetry
    @(feat) median(feat)+2*mad(feat), ...
    @(feat) min(2, prctile(feat, 50))};    
opt.RetainedVar     = 99.75;
opt.MaxPCs          = 35;
opt.MinPCs          = @(lambda) max(3, ceil(0.1*numel(lambda)));
opt.BSS             = spt.bss.efica;

[thisArgs, varargin] = split_arguments(opt, varargin);

[~, opt] = process_arguments(opt, thisArgs);

%% Default criterion
% The symmetry feature is not very reliable to identify ocular components.
myFeat1 = spt.feature.topo_symmetry;
myFeat2 = spt.feature.topo_frontal;
myFeat3 = spt.feature.psd_ratio.eog;
myCrit  = spt.criterion.threshold('Feature', {myFeat1, myFeat2, myFeat3}, ...
    'Max',                  opt.Max, ...
    'MinCard',              opt.MinCard, ...
    'MaxCard',              opt.MaxCard, ...
    'RankingFactor',        [1 1 2]); %Only relevant if MinCard is in effect


%% PCA
myFilter = @(sr) filter.lpfilt('fc', 13/(sr/2));
myPCA = spt.pca(...
    'RetainedVar',              opt.RetainedVar, ...
    'MaxCard',                  opt.MaxPCs, ...
    'MinCard',                  opt.MinPCs, ...
    'MinSamplesPerParamRatio',  15, ...
    'LearningFilter',           myFilter);

%% Build the bss node
% Note: we do not anymore use a LASIP filter to post-process the EOG
% components ('Filter', filter.lasip.eog). 
dataSel = cascade(sensor_class('Class', {'EEG', 'MEG'}), good_data);
obj = meegpipe.node.bss.new(...
    'DataSelector', dataSel, ...
    'Criterion',    myCrit, ...
    'PCA',          myPCA, ...
    'BSS',          opt.BSS, ...
    'RegrFilter',   filter.mlag_regr('Order', 5), ...
    'Name',         'bss.eog', ...
    varargin{:});


end