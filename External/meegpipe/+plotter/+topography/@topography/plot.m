function h = plot(h, sensors, data)
% PLOT - Plots topography of physioset
%
% plot(h, sensors, data)
%
% Where
%
% H is a plotter.topography handle
%
% DATA is a Nx1 vector containing the values to be plotted at each sensor
% location.
%
% SENSORS is a sensors.eeg or sensors.meg object containing the locations
% of each sensor.
%
%
% See also: pset.plot.space.topography


import plotter.topography.topography;
import misc.nn_match;


if ~has_coords(sensors),
    h = [];
    return;
end

opt.sensors     = get_config(h, 'Sensors');
opt.fiducials   = get_config(h, 'Fiducials');
opt.extra       = get_config(h, 'Extra');

if isempty(h.Figure),
    if get_config(h, 'Visible'),
        visible = 'on';
    else
        visible = 'off';
    end
    h.Figure = figure('Visible', visible);
else
    figure(h.Figure);
end

elecPnt     = eeglab(sensors);
if isa(sensors, 'sensors.eeg'),
    % Fiducials/extra considered only for EEG and not for MEG sensors
    fidPnt      = eeglab(sensors, 'fiducials'); %#ok<*NASGU>
    extraPnt    = eeglab(sensors, 'extra');
else
    fidPnt      = [];
    extraPnt    = [];
end
% Guess the right value for property PlotRad
if isempty(elecPnt(1).radius),
    radius = 1;
else
    radius = max(arrayfun(@(x) x.radius, elecPnt));
end

% topoplot() only accepts radius between 0.15 and 1
radius = max(0.16, radius);
raduis = min(1, radius);

% We use evalc to avoid displaying messages from EEGLAB's topoplot
args = topoplot_args(h); %#ok<NASGU>
evalc(['topoplot(double(data), elecPnt, args{:}, ', ...
    '''Electrodes'', ''ptslabels'', ''PlotRad'', radius)']);

h.Axes   = gca;

if get_config(h, 'ColorBar'),
    h.ColorBar = colorbar;
end

% Handle to head contour
h.HeadContour = findobj(h.Axes, ...
    'Type',         'patch', ...
    'FaceColor',    get_config(h, 'HColor'));
% Handles to ears and nose
h.EarsAndNose = findall(h.Figure, ...
    'Type',     'line', ...
    'Marker',   'none');

% Handle to contour plot RIM
h.Rim = findobj(h.Axes, ...
    'Type',         'patch', ...
    'FaceColor',    get(h.Figure, 'Color'));

% Handle to the contourplot surface and contour lines
h.ContourSurface = findobj(h.Figure, ...
    'Type',     'surface');

h.ContourLines    = findobj(h.Figure, ...
    'Type',     'hggroup');


% Handle to the sensors label texts
h.SensorLabels = findobj(h.Axes, ...
    'Type', 'Text');

% There may be some spurious texts that do not correspond to sensor labels
isEmpty = arrayfun(@(x) isempty(get(x, 'UserData')), h.SensorLabels);
h.SensorLabels(isEmpty) = [];

% Re-order the labels
plotOrder = cellfun(@(x) str2double(x), get(h.SensorLabels, 'UserData'));
[~, plotReOrder] = sort(plotOrder, 'ascend');
h.SensorLabels = h.SensorLabels(plotReOrder);

% Labels' positions (to match them with markers)
labelPos = nan(numel(h.SensorLabels), 3);
for i = 1:numel(h.SensorLabels)
    labelPos(i, :) = get(h.SensorLabels(i), 'Position');
end

% We want to be able to manipulate individual markers separately
sMarkers = findobj(h.Axes, 'Marker', '.');
XData = get(sMarkers, 'XData');
YData = get(sMarkers, 'YData');
ZData = get(sMarkers, 'ZData');
h.SensorMarkers = nan(numel(XData), 1);
for i = 1:numel(XData)
    h.SensorMarkers(i) = copyobj(sMarkers, h.Axes);
    set(h.SensorMarkers(i), ...
        'XData', XData(i), ...
        'YData', YData(i), ...
        'ZData', ZData(i) ...
        );
end

% Re-order the markers to match the labels' order
markerPos = [XData(:), YData(:), ZData(:)];

order = nn_match(markerPos, labelPos);

h.SensorMarkers = h.SensorMarkers(order,:);

delete(sMarkers);

% Be sure that those are really sensor labels
% Sometimes a weird empty text appears somewhere...
if numel(h.SensorLabels) > numel(elecPnt),
    isValid = false(1, numel(h.SensorLabels));
    for i = 1:numel(h.SensorLabels),
        thisLabel = get(h.SensorLabels(i), 'String');
        for j = 1:numel(elecPnt),
            if ~isempty(regexpi(thisLabel, elecPnt(j).labels)),
                isValid(i) = true;
                break;
            end
        end
    end
    delete(h.SensorLabels(~isValid));
    h.SensorLabels(~isValid) = [];
end

h.Data       = data;
sensorLabels    = get_sensor_labels(h, 'String');
h.Sensors    = [...
    mat2cell((1:numel(sensorLabels))', ones(numel(sensorLabels),1)), ...
    sensorLabels];

if ~isempty(h.Sensors),
    markerSize = get_sensor_markers(h, 1, 'MarkerSize');
else
    markerSize = 3;
end

% Plot fiducial locations
set_sensor_markers(h, 'Visible', 'off');
set_sensor_labels(h,  'Visible', 'off');

if isa(sensors, 'sensors.eeg') && ~isempty(fiducials(sensors)),
    % We use evalc to prevent EEGLAB from displaying distracting status
    % messages, especially while running within SGE.
    evalc(['topoplot(data, fidPnt, ''Electrodes'', ''ptslabels'', ' ...
        '''Style'', ''blank'', ''HColor'', ''none'', ''PlotRad'', radius)']);
    
    h.FiducialMarkers = findobj(h.Axes, ...
        'Marker', '.', 'Visible', 'on');
    tmp = findobj(h.Axes, ...
        'Type', 'Text', 'Visible', 'on');
    isLabel = arrayfun(@(x) ismember(get(x, 'String'), ...
        keys(fiducials(sensors))), tmp);
    delete(tmp(~isLabel));
    tmp(~isLabel) = [];
    h.FiducialLabels = tmp;
    delete(title(''));
    set_fiducial_markers(h, ...
        'MarkerSize',       markerSize*1.25, ...
        'MarkerEdgeColor',  'blue', ...
        'MarkerFacecolor',  'blue', ...
        'Marker', '^');
    set_fiducial_markers(h,  'Visible', 'off');
    set_fiducial_labels(h,   'Visible', 'off');
    fidLabels = get_fiducial_labels(h, 'String');
    if ~isempty(fidLabels),
        h.Fiducials    = [...
            mat2cell((1:numel(fidLabels))', ones(numel(fidLabels),1)), ...
            fidLabels];
    else
        h.Fiducials = [];
    end
end

% Plot extra locations
if isa(sensors, 'sensors.eeg') && ~isempty(extra(sensors)),
    evalc(['topoplot(data, extraPnt, ''Electrodes'', ''ptslabels'', ' ...
        '''Style'', ''blank'', ''HColor'', ''none'', ''PlotRad'', radius)']);
    h.ExtraMarkers = findobj(h.Axes, ...
        'Marker', '.', 'Visible', 'on');
    tmp = findobj(h.Axes, ...
        'Type', 'Text', 'Visible', 'on');
    isLabel = arrayfun(@(x) ismember(get(x, 'String'), ...
        keys(extra(sensors))), tmp);
    delete(tmp(~isLabel));
    tmp(~isLabel) = [];
    h.ExtraLabels = tmp;
    delete(title(''));
    set_extra_markers(h, ...
        'MarkerSize',       markerSize*1.25, ...
        'MarkerEdgeColor',  'red', ...
        'MarkerFacecolor',  'red', ...
        'Marker', 's');
    set_extra_markers(h,     'Visible', 'off');
    set_extra_labels(h,      'Visible', 'off');
    extraLabels = get_extra_labels(h, 'String');
    if ischar(extraLabels), extraLabels = {extraLabels}; end
    if ~isempty(extraLabels),
        h.Extra   = [...
            mat2cell((1:numel(extraLabels))', ones(numel(extraLabels),1)), ...
            extraLabels];
    else
        h.Extra = [];
    end
end

set_sensor_markers(h,    'Visible', 'on');
set_sensor_labels(h,     'Visible', 'on');

if strcmpi(opt.sensors, 'off'),
    set_sensor_markers(h, 'Visible', 'off');
    set_sensor_labels(h, 'Visible', 'off');
elseif strcmpi(opt.sensors, 'on'),
    set_sensor_labels(h, 'Visible', 'off');
elseif strcmpi(opt.sensors, 'labels'),
    set_sensor_markers(h, 'Visible', 'off');
elseif strcmpi(opt.sensors, 'numbers'),
    labels2numbers(h);
    set_sensor_makers(h, 'Visible', 'off');
elseif strcmpi(h.Sensor, 'ptsnumbers'),
    labels2numbers(h);
end

if strcmpi(opt.fiducials, 'ptslabels'),
    set_fiducial_markers(h, 'Visible', 'on');
    set_fiducial_labels(h, 'Visible', 'on');
elseif strcmpi(opt.fiducials, 'on'),
    set_fiducial_markers(h, 'Visible', 'on');
elseif strcmpi(opt.fiducials, 'labels'),
    set_fiducial_labels(h, 'Visible', 'on');
end

if strcmpi(opt.extra, 'ptslabels'),
    set_extra_markers(h, 'Visible', 'on');
    set_extra_labels(h, 'Visible', 'on');
elseif strcmpi(opt.extra, 'on'),
    set_extra_markers(h, 'Visible', 'on');
elseif strcmpi(opt.extra, 'labels'),
    set_extra_labels(h, 'Visible', 'on');
end


end
