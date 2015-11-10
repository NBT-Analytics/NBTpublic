function myNode = regression(varargin)
% REGRESSION - EOG correction by regressing out EOG channels

import misc.process_arguments;
import misc.split_arguments;

% The indices of the EOG channels, or a list of channel labels
opt.EOGChannels = [];
opt.Order       = 3;
[thisArgs, varargin] = split_arguments(fieldnames(opt), varargin);

[~, opt] = process_arguments(opt, thisArgs);

% First node takes care of selecting the EOG channels
if isempty(opt.EOGChannels), 
    mySel = pset.selector.sensor_label('EOG');
elseif isnumeric(opt.EOGChannels),
    % A list of channel indices
    mySel = pset.selector.sensor_idx(opt.EOGChannels);
elseif iscell(opt.EOGChannels),
    % A list of channel labels
    chanLabels = cellfun(@(x) ['^' x '$'], opt.EOGChannels, ...
        'UniformOutput', false);
    mySel = pset.selector.sensor_label(chanLabels);
end    

% Second node is a dummy (transparent) node
myNode = meegpipe.node.rfilter.new(...
    'RegrSelector',   mySel, ...
    'TargetSelector', ~mySel, ...
    'Name',           'eog-regr', ...
    varargin{:});
   

end