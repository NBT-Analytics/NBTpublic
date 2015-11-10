function obj = pwl(varargin)
% PWL - Default bss node configuration for PWL correction

import misc.process_arguments;
import misc.split_arguments;
import pset.selector.sensor_class;
import pset.selector.good_data;
import pset.selector.cascade;

%% Process user arguments
opt.MaxPCs          = 40;
opt.MinPCs          = @(lambda) min(8, ceil(0.05*numel(lambda)));
opt.RetainedVar     = 99.85;
opt.BSS             = spt.bss.multicombi;

[thisArgs, varargin] = split_arguments(fieldnames(opt), varargin);

[~, opt] = process_arguments(opt, thisArgs);

%% PCA
myFilter = @(sr) filter.bpfilt('fp', [35 150]/(sr/2));
myPCA = spt.pca(  ...
        'LearningFilter',   myFilter, ...
        'RetainedVar',      opt.RetainedVar, ...
        'MaxCard',          opt.MaxPCs, ...
        'MinCard',          opt.MinPCs, ...
        'MaxCond',          1000); 
    
%% Component selection criterion
myFeat = spt.feature.psd_ratio.pwl;

myCrit = spt.criterion.threshold(myFeat, ...
    'Max',      20, ...
    'MaxCard',  4, ...
    'MinCard',  0);

%% Build the bss node
dataSel = cascade(sensor_class('Class', {'MEG', 'EEG'}), good_data);
obj = meegpipe.node.bss.new(...
    'DataSelector',         dataSel, ...
    'Criterion',            myCrit, ...
    'PCA',                  myPCA, ...
    'BSS',                  opt.BSS, ...
    'Name',                 'pwl', ...
    varargin{:});
    


end