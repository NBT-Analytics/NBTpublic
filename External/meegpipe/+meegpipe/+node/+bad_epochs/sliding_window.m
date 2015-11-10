function obj = sliding_window(period, dur, varargin)
% SLIDING_WINDOW - Reject sliding windows with large variance

import meegpipe.node.bad_epochs.criterion.stat.stat;
import meegpipe.node.pipeline.pipeline;
import meegpipe.node.*;
import physioset.event.periodic_generator;
import datahash.DataHash;

if nargin < 1 || isempty(period),
    period = 1;  % in seconds
end

if nargin < 2 || isempty(dur),
    dur = 2*period; % in seconds
end

if ~isnumeric(period) || ~isnumeric(dur) || period < 0 || dur < 0,
    error('Both period and duration must be positive scalars');
end

% Reject at most 20% of the epochs. Thus the prctile(x, 20)
crit = stat('Max', @(x) max(prctile(x, 80), min(400, prctile(x, 99))));

evGen = periodic_generator(...
    'Period',   period, ...
    'Duration', dur, ...
    'Type',     '__BadEpochsEvent', ...
    'FillData', true);

node1 = ev_gen.new('EventGenerator', evGen, 'GenerateReport', false);

evSel = physioset.event.class_selector('Type', '__BadEpochsEvent');

% Node properties -> to the pipeline
% Node config options -> to the bad epochs node
nodeProps = {'Name', 'DataSelector', 'Parallelize', 'IOReport', ...
    'GenerateReport', 'Queue', 'Save', 'TempDir'};
[pipeArgs, varargin] = misc.split_arguments(nodeProps, varargin);

node2 = bad_epochs.new(...
    'Criterion',        crit, ...
    'DeleteEvents',     true, ...
    'EventSelector',    evSel, ...
    varargin{:});

obj = pipeline('NodeList', {node1, node2}, ...
    'Name', 'bad_epochs.sliding_window_var', ...
    pipeArgs{:});

end