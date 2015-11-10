% DEMO - Demonstrates class eegplot functionality
%
% To run demo use the command:
%
% plotter.eegplot.demo
%
%
% (c) German Gomez-Herrero <german.gomezherrero@kasku.org>
%
%
% See also: eegplot, make_test

if ~exist('VISIBLE', 'var') || isempty(VISIBLE), %#ok<*NODEF>
    VISIBLE = true;
end

if ~exist('INTERACTIVE', 'var') || isempty(INTERACTIVE),
    INTERACTIVE = VISIBLE;    
end

if INTERACTIVE,  VISIBLE = true; end

if VISIBLE, echo on; close all; clc; end

% Define the plotter configuration, e.g. we want data to be plotted
% in different colors for each channel:
import plotter.eegplot.*;
myConfig = config('SamplingRate', 100);
if INTERACTIVE, pause; clc;  end

% The configuration object is optional
h = eegplot(myConfig);
if INTERACTIVE, pause; clc;  end

% Create some sample sensors
sensorsObj = sensors.eeg.from_template('egi256');
if INTERACTIVE, pause; clc;  end


% Plot some random data (using overlays)
myEvent   = pset.event.event(50, 'Type', 'myEvent');
d1        = randn(10, 100);
d2        = randn(10, 100);
d3        = randn(10, 100);
h = plot(h, d1, d2, d3, 'Events', myEvent);
set_sensor_labels(h, labels(subset(sensorsObj, 1:10)));
if INTERACTIVE, pause; clc;  end

% Use a black background color
blackbg(h);
if INTERACTIVE, pause; clc;  end

% Create a clone figure
h2 = clone(h);
if INTERACTIVE, pause; clc;  end