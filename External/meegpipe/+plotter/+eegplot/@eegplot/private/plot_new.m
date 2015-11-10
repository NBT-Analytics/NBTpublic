function obj = plot_new(obj, data, varargin)

%import external.eeglab.eegplot;
import misc.process_arguments;
import plotter.rnd_colors;
import eeglab.eegplot;

% Disallow some eegplot options
badOptions = {'data2', 'winlength'};
idx = find(cellfun(@(x) ischar(x) && ismember(x, badOptions), varargin));
if ~isempty(idx),
    varargin([idx idx+1]) = [];
end

% Check if the sampling rate was provided
opt.srate = get_config(obj, 'SamplingRate');

[~, opt] = process_arguments(opt, varargin);

obj.NbPoints        = size(data,2);
obj.NbDims          = size(data,1);

% Create a new figure, maybe an invisible one
if get_config(obj, 'Visible'),
    visible = 'on';
else
    visible = 'off';
end

% IMPORTANT: for whatever reason mean(data,2) makes MATLAB 2014a crash
% badly on somerenserver (Centos 6.5 Linux). No clue why... this is a quick
% and dirty fix only.
data = data - repmat(misc.row_mean(data), 1, size(data,2)); 
winLength = max(1, ceil(obj.NbPoints/opt.srate));

% We use evalc to avoid messages from EEGLAB's eegplot
evalc(sprintf(['eegplot(''noui'', data, varargin{:}, ''winlength'', ' ...
    '%d, ''visible'', ''%s'');'], winLength, visible));

% Remove annoying callbacks
set(gcf, ...
    'WindowButtonDownFcn',      [], ...
    'WindowButtonMotionFcn',    [], ...
    'WindowButtonUpFcn',        []);

obj.Figure          = gcf;
obj.Axes            = findobj(obj.Figure, 'Tag', 'eegaxis');
obj.AxesBg          = findobj(obj.Figure, 'Tag', 'backeeg');
obj.EyeLine         = findobj(obj.Figure, 'Tag', 'eyeline');
tmp                 = findobj(obj.Figure, 'Type', 'line');
tmp                 = setdiff(tmp, obj.EyeLine);
% Separate "event" lines from time series lines
isEvent             = arrayfun(@(x) numel(get(x, 'YData')) < 3, tmp);
obj.EventLine       = tmp(isEvent);
obj.Line            = {flipud(tmp(~isEvent))};

% Number of TSs might differ from number of lines if the current epoch
% contains "bad samples". If there are two bad sample periods within the
% current epoch you should expect 3 times as many lines as number of TSs
obj.NbTimeSeries    = size(data,1);

obj.Scale           = findobj(obj.Figure, ...
    'Type', 'text', 'Tag', 'thescale');

obj.ScaleNum        = findobj(obj.Figure, ...
    'Type', 'text', 'Tag', 'thescalenum');

obj.ScaleVal        = str2double(get_scale_label(obj, 'String'));
tmp = get(obj.Line{1}, 'YData');

if ~iscell(tmp), tmp = {tmp}; end

obj.MeanVal = cellfun(@(x) mean(x), tmp);

obj.EventLabel = findobj(obj.Figure, 'Type', 'text', 'Tag', '');

% Regenerate line colors
if prod(get(gcf, 'Color')) < 0.0001,
    background = 'dark';
else
    background = 'light';
end

lineColor = rnd_colors(1, 'Background', background);
set_line(obj, [], 'Color', lineColor);


end