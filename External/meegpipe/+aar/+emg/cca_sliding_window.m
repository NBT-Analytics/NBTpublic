function myNode = cca_sliding_window(varargin)
% CCA_SLIDING_WINDOW - EMG correction using sliding window CCA
%
% ## Usage synopsis
% 
% myNode = aar.emg.cca_sliding_window('key', value, ...)
%
% 
% ## Accepted key/value configuration pairs:
%
% WindowLength      :  The length of the sliding window in seconds    
%                      Default: 5
%
% WindowOverlap     :  The overlap (in percentage) between correlative
%                      CCA windows. Increasing this value generally leads
%                      to better correction but considerably increases
%                      computation time. 
%                      Default: 50
% 
% CorrectionTh      :  A correction threshold in percentage. Increasing
%                      Correction will lead to a harsher correction.
%                      Default: 25
%
% VarTh             :  Variance threshold in percentage. This parameter is
%                      used to control the number of CCA components. 
%                      Default: 99.99
%
%
% See also: filter.cca, bss.node.filter, filter.sliding_window


import misc.process_arguments;
import misc.split_arguments;
import aar.emg.cca_sliding_window.*;

opt.WindowLength = 5;
opt.CorrectionTh = 25;
opt.VarTh        = 99.999; 
opt.WindowOverlap = 50;
opt.MinPCs       = @(lambda) max(2, 0.25*numel(lambda));
[thisArgs, varargin] = split_arguments(fieldnames(opt), varargin);

[~, opt] = process_arguments(opt, thisArgs);

if opt.CorrectionTh < 1,
    warning('cca_sliding_window:CorrectionThMustBePercentage', ...
        'CorrectionTh < 1. Are you sure CorrectionTh is a percentage?');
end

if opt.CorrectionTh < 0 || opt.CorrectionTh > 100
   error('cca_sliding_window:CorrectionThMustBePercentage', ...
       'Invalid CorrectionTh: must be a percentage (in the range 0-100)'); 
end

myPCA = spt.pca(...
    'RetainedVar',  opt.VarTh, ...
    'MinCard',      opt.MinPCs);

myCCA = spt.bss.cca(...
    'MinCorr', opt.CorrectionTh/100, ...
    'MaxCard', @(x) ceil(0.9*numel(x)));
myFilter = filter.cca('CCA', myCCA);

myFilter = filter.pca(...
    'PCA',      myPCA, ...
    'PCFilter', myFilter);

myFilter = filter.sliding_window(myFilter, ...
    'WindowLength', @(sr) opt.WindowLength*sr, ...
    'WindowOverlap', opt.WindowOverlap);

mySel = pset.selector.sensor_class('Class', 'EEG');

myGlobalPCA = spt.pca(...
    'RetainedVar',  99.99999, ...
    'MinCard',      @(lambda) max(2, 0.5*numel(lambda)));
myNode = meegpipe.node.filter.new(...
    'Name',         'emg-cca', ...
    'DataSelector', mySel, ...
    'Filter',       myFilter, ...
    'PCA',          myGlobalPCA, ...
    varargin{:});


end