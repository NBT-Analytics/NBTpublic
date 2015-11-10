% DEMO - Demonstrates class fvtool2 functionality
%
% To run demo use the command:
%
% plotter.fvtool2.demo
%
%
% (c) German Gomez-Herrero <german.gomezherrero@kasku.org>
%
%
% See also: fvtool2, make_test

import plotter.fvtool2.*;

if ~exist('VISIBLE', 'var') || isempty(VISIBLE), %#ok<*NODEF>
    VISIBLE = true;
end

if ~exist('INTERACTIVE', 'var') || isempty(INTERACTIVE),
    INTERACTIVE = VISIBLE;    
end

if INTERACTIVE,  VISIBLE = true; end

if VISIBLE, echo on; close all; clc; end

%% Build a couple filters and plot them in same figure
f1 = filter.hpfilt('Fc', .7);
f2 = filter.lpfilt('Fc', .2);
h = fvtool2(mdfilt(f1), mdfilt(f2), 'Visible', VISIBLE);

if INTERACTIVE, pause; clc; end


%% Plot a third filter in a new figure, plot also filter phase
f3 = filter.bpfilt('Fp', [.3 .6]);
h = fvtool2(h, mdfilt(f3), 'Visible', VISIBLE, 'Analysis', 'freq');

if INTERACTIVE, pause; clc; end

%% Change some properties in all figures
set_axes(h, 'FontSize', 18, 'LineWidth', 2);
set_line(h, 'Color', 'Black');

if INTERACTIVE, pause; clc; end

%% Change the color of the phase lines to red
set_line(h, {'phase'}, 'Color', 'Red');

if INTERACTIVE, pause; clc; end

%% Add a legend to each figure
select(h, 1);
legend(h, 'Filter 1', 'Filter 2');
select(h, 2);
legend(h, 'Filter X');

if INTERACTIVE, pause; clc; end

%% Change the color of the Filter 1 line to blue
select(h, []);
set_line(h, {'Filter 1'}, 'Color', 'Blue');

if INTERACTIVE, pause; clc; end

%% Change the legend properties in all figures
select(h, []);
set_legend(h, 'FontSize', 15);

if INTERACTIVE, pause; clc; end

%% Set title, xlabel and ylabel properties
select(h, []);
set_title(h, 'FontWeight', 'Bold');
set_xlabel(h, 'FontWeight', 'Bold');
set_ylabel(h, 'FontWeight', 'Bold');

if INTERACTIVE, pause; clc; end

clear h ans;


