function obj = bcg(varargin)
% BCG - Static constructor for BCG identification purposes
%
% See also: xcorr

import pset.selector.sensor_class;

obj = spt.feature.xcorr(...
    'RefSelector',     sensor_class('Type', 'ECG'), ...
    'AggregatingStat',  @(x) max(x), ...   
    varargin{:});


end