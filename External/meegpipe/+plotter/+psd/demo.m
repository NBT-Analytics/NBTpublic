% DEMO - Demonstrates class eegplot functionality
%
% To run demo use the command:
%
% plotter.psd.demo
%
%
% (c) German Gomez-Herrero <german.gomezherrero@kasku.org>
%
%
% See also: plotter.psd.psd, plotter.psd.make_test

import plotter.psd.root_path;
import mperl.file.spec.catfile;

if ~exist('VISIBLE', 'var') || isempty(VISIBLE), %#ok<*NODEF>
    VISIBLE = true;
end

if ~exist('INTERACTIVE', 'var') || isempty(INTERACTIVE),
    INTERACTIVE = VISIBLE;    
end

if INTERACTIVE,  VISIBLE = true; end

if VISIBLE, echo on; close all; clc; end

% Load some sample data
x      = dlmread(catfile(root_path, 'x.csv'));
xfilt  = dlmread(catfile(root_path, 'xfilt.csv'));
xfilt2 = dlmread(catfile(root_path, 'xfilt2.csv'));

% A PSD estimation algorithm
h     = spectrum.welch('Hamming', 125);

% Create a PSD estimate (a dspdata.psd object)
hpsd  = psd(h, x, 'Fs', 125, 'ConfLevel', 0.99);

% Create a PSD plotter (by default: VISIBLE = true)
hp    = plotter.psd.psd('Visible', VISIBLE);

% Plot the PSD
hp = plot(hp, hpsd);
if INTERACTIVE, pause; clc; end

% Create a second PSD estimate
hpsd2  = psd(h, xfilt, 'Fs', 125, 'ConfLevel', 0.95);

% Plot it on the same figure as hpsd, in red color
hp = plot(hp, hpsd2, 'r');
if INTERACTIVE, pause; clc; end

% Create a third PSD (this time without Conf. Interval computation)
hpsd3  = psd(h, xfilt2, 'Fs', 125);

% And plot it as well, this time in Blue
hp = plot(hp, hpsd3, 'b');
if INTERACTIVE, pause; clc; end

% Make the plot transparent
set_config(hp, 'Transparent', true);
if INTERACTIVE, pause; clc; end

% Hide the Conf. intervals
set_config(hp, 'ConfInt', false);
if INTERACTIVE, pause; clc; end

% Make the conf. intervals VISIBLE
set_config(hp, 'ConfInt', true);
if INTERACTIVE, pause; clc; end

% Change the PSD names to something more meaningful
hp = set_psdname(hp, 1, 'Original signal');
hp = set_psdname(hp, 2, 'Scaled+filtered signal');
hp = set_psdname(hp, 3, 'Scaled+filtered signal');
if INTERACTIVE, pause; clc; end

% Make the PSD main lines thicker
hp = set_line(hp, 1:3, 'LineWidth', 2);
if INTERACTIVE, pause; clc; end

% Match the scale of the PSDs (in order to compare their shapes better)
hp = match_scale(hp);
if INTERACTIVE, pause; clc; end

% Match the scale only in the band from 10 to 25 Hz
hp = match_scale(hp, [5 25]);
if INTERACTIVE, pause; clc; end

% Go back to the original PSD scales
hp = orig_scale(hp);
if INTERACTIVE, pause; clc; end

% Clone the figure
hpClone = clone(hp);
if INTERACTIVE, pause; clc; end

% Hide the legend in the cloned figure
hpClone = set_legend(hpClone, 'Visible', 'off');
if INTERACTIVE, pause; clc; end

% Make the figure have a black background
hpClone = blackbg(hpClone);
if INTERACTIVE, pause; clc; end

% Randomize the colors of the PSDs
hpClone = rnd_line_colors(hpClone, 'MinLuminance', 0.5, 'MinDistance', 0.2);
if INTERACTIVE, pause; clc; end

% Change properties of axes labels and figure title
hpClone = set_title(hpClone,  'FontWeight', 'bold', 'Fontsize', 12);
hpClone = set_xlabel(hpClone, 'FontWeight', 'bold');
hpClone = set_ylabel(hpClone, 'FontWeight', 'bold');
if INTERACTIVE, pause; clc; end

% Set the legend back on and hide the entries corresp. to conf. intervals
hpClone = set_legend(hpClone, 'VISIBLE', 'on');
set(hpClone, 'ConfIntLegend', false);
if INTERACTIVE, pause; clc; end

% Focus on the frequencies within the range from 5 to 30 Hz
set_config(hpClone, 'FrequencyRange', [5 30]);
if INTERACTIVE, pause; clc; end

% Go back to the original frequency range
set_config(hpClone, 'FrequencyRange', [-Inf Inf]);
if INTERACTIVE, pause; clc; echo off; end

