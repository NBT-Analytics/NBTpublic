function obj = minmax(minVal, maxVal, varargin)
% MINMAX - Reject epochs that exceed Min/Max thresholds

import meegpipe.node.bad_epochs.criterion.stat.stat;
import meegpipe.node.pipeline.pipeline;
import meegpipe.node.bad_epochs.bad_epochs;

if nargin < 2, maxVal = 80; end
if nargin < 1, minVal = -80; end

crit1 = stat(...
    'ChannelStat',   @(x) max(x), ...
    'EpochStat',     @(x) max(x), ...
    'Max',           maxVal);

crit2 = stat(...
    'ChannelStat',   @(x) min(x), ...
    'EpochStat',     @(x) min(x), ...  
    'Min',           minVal);

obj1 = bad_epochs('Criterion', crit1, varargin{:});

obj2 = bad_epochs('Criterion', crit2, varargin{:});

obj = pipeline('NodeList', {obj1, obj2});



end