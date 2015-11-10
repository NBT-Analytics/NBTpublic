function obj = ecg(varargin)
% ECG - Default bss node configuration for ECG rejection

import misc.process_arguments;
import misc.split_arguments;
import pset.selector.sensor_class;
import pset.selector.good_data;
import pset.selector.cascade;

%% Process input arguments

myFilter = @(sr) filter.bpfilt('fp', [3/(sr/2) 48/(sr/2);52/(sr/2) 1]);

opt.MinCard         = 0;
opt.MaxCard         = 4;
opt.CorrTh          = 0.6; % Correlation threshold
opt.RetainedVar     = 99.75; 
opt.BSS             = spt.bss.efica('LearningFilter', myFilter);

[thisArgs, varargin] = split_arguments(fieldnames(opt), varargin);

[~, opt] = process_arguments(opt, thisArgs);

%% PCA
myPCA = spt.pca(...
    'RetainedVar',      opt.RetainedVar, ...
    'MaxCard',          40, ... 
    'MinCard',          @(lambda) min(30, max(2, 0.1*numel(lambda))), ...
    'LearningFilter',   myFilter);

%% Component selection criterion
myFeat1 = spt.feature.qrs_erp('Filter', myFilter);

% In rare occassions alpha components are confused with ECG-related
% components. This second feature should prevent any alpha-component to be
% picked.
myFeat2 = spt.feature.psd_ratio(...
    'TargetBand',       [1 6], ...
    'RefBand',          [7 12], ...
    'RefBandStat',      @(feat) mean(feat), ...
    'TargetBandStat',   @(feat) mean(feat));
    
myCrit = spt.criterion.threshold(myFeat1, myFeat2, ...
    'MinCard',  opt.MinCard, ...
    'MaxCard',  opt.MaxCard, ...
    'Max',      {0.6 1});

%% Build the bss node
dataSel = cascade(sensor_class('Class', {'MEG', 'EEG'}), good_data);
obj = meegpipe.node.bss.new(...  
    'DataSelector',     dataSel, ...
    'Criterion',        myCrit, ...
    'PCA',              myPCA, ...
    'BSS',              opt.BSS, ...
    'RegrFilter',       filter.mlag_regr('Order', 5), ...
    'Name',             'bss.ecg', ...
    varargin{:});


end