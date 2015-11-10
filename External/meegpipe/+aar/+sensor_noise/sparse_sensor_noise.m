function obj = sparse_sensor_noise(varargin)
% SPARSE_SENSOR_NOISE - Correct noise generated at a single sensor

import misc.process_arguments;
import misc.split_arguments;
import pset.selector.sensor_class;
import pset.selector.good_data;
import pset.selector.cascade;

%% Process input arguments
opt.MinCard         = 1;
opt.MaxCard         = @(d) min(10, ceil(0.25*numel(d)));
opt.MinPCs          = @(lambda) min(20, 0.5*numel(lambda));
opt.MaxPCs          = 40;
opt.RetainedVar     = 99.9; 
opt.BSS             = spt.bss.efica;
opt.Max             = {@(fVal) ceil(0.7*numel(fVal))};

[thisArgs, varargin] = split_arguments(fieldnames(opt), varargin);
[~, opt] = process_arguments(opt, thisArgs);

%% PCA
myPCA = spt.pca(...
    'RetainedVar',      opt.RetainedVar, ...
    'MinCard',          opt.MinPCs, ...
    'MaxCard',          opt.MaxPCs);

%% Component selection criterion
myFeat1 = spt.feature.skurtosis;

myCrit  = spt.criterion.threshold(myFeat1, ...
    'Max',     opt.Max, ...
    'MinCard', opt.MinCard, ...
    'MaxCard', opt.MaxCard);

%% Build the bss node
dataSel = cascade(sensor_class('Class', {'EEG', 'MEG'}), good_data);
obj = meegpipe.node.bss.new(...
    'DataSelector', dataSel, ...
    'Criterion',    myCrit, ...
    'PCA',          myPCA, ...
    'BSS',          opt.BSS, ...
    'Name',         'sparse_sensor_noise', ...
    varargin{:});

end