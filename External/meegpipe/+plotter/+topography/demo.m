% DEMO - Demonstrates class topography functionality
%
% To run demo use the command:
%
% plotter.topography.demo
%
%
% (c) German Gomez-Herrero <german.gomezherrero@kasku.org>
%
%
% See also: plotter.topography.topography, plotter.topography.make_test

if ~exist('VISIBLE', 'var') || isempty(VISIBLE), %#ok<*NODEF>
    VISIBLE = true;
end

if ~exist('INTERACTIVE', 'var') || isempty(INTERACTIVE),
    INTERACTIVE = VISIBLE;    
end

if INTERACTIVE,  VISIBLE = true; end

if VISIBLE, echo on; close all; clc; end

% Define the plotter configuration
import plotter.topography.*;
cfg = config('Fiducials', 'off');
if INTERACTIVE, pause; clc;  end

% A configuration object is optional
obj = topography(config);
if INTERACTIVE, pause; clc;  end

% Create some sample sensors
sensorsObj = sensors.eeg.from_template('egi256');
if INTERACTIVE, pause; clc;  end

% Plot a random topography and get a handle to the result
h = plot(obj, sensorsObj, rand(nb_sensors(sensorsObj),1));
if INTERACTIVE, pause; clc;  end

% Do not show ears and nose
set_ears_and_nose(h, 'Visible', 'off');
if INTERACTIVE, pause; clc;  end

% Display a colorbar and then hide it
colorbar(h);
set_colorbar(h, 'Visible', 'off');
if INTERACTIVE, pause; clc;  end

% Display sensor labels in a tiny font
set_sensor_labels(h, 'Visible', 'on', 'FontSize', 6);
if INTERACTIVE, pause; clc;  end

% Use sensor numbers instead of labels
labels2numbers(h);
if INTERACTIVE, pause; clc;  end

% Invert the colors of the figure (i.e. use a black background)
blackbg(h);
if INTERACTIVE, pause; clc;  end