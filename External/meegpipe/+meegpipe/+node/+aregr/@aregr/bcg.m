function obj = bcg(varargin)
% BCG - Rejects BCG-like components
%
%
%


import pset.selector.sensor_class;
import spt.pca.pca;
import meegpipe.node.aregr.aregr;
import filter.mlag_regr;

% Regressor selection
regSel  = sensor_class('Type', 'cw');
dataSel = sensor_class('Class', 'eeg');

% Filter
filtObj = mlag_regr;

% Build an empty bss_regression object
obj = aregr(...
    'Filter',           filtObj, ...  
    'Regressor',        regSel, ...
    'Measurement',      dataSel, ...
    'IOReport',         report.plotter.io, ...
    varargin{:});

if isempty(get_name(obj)),
    obj = set_name(obj, 'aregr.bcg');
end

end