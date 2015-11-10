function obj = blackbg(obj, varargin)
% BLACKBG - Sets a black background for a plotter.eegplot figure
%
% blackbg(h)
% blackbg(h, 'ForeColor', [0.7 0.7 0.7])
%
%
% Where
%
% H is a plotter.eegplot handle
%
%
% ## Optional key/value pairs:
%
% You can specify optional arguments as key/value pairs (see second and
% third example in the usage synopsis above).
%
%       ForeColor:  A 1x3 numeric array. Default: [1 1 1], i.e. white
%           Defines the foreground color for the figure.
%
%       AxesColor: A 1x3 numeric array. Default: 0.8*ForeColor
%           Defines the color of the figure axes.
%
%       MinDist: A numeric scalar in the range (0,1). Default: 0.1
%           Minimum Euclidean distance between two different line colors
%
%       MinLuminance: A numeric scalar in the range (0,1). Default: 0
%           Minimum color luminance
%
%       InitGuess: A Kx3 matrix with RGB color specifications. Default: []
%           A initial set of colors can be provided using this argument. If
%           not provided, the current line colors will be used as initial
%           guess.
%
%
% See also: plotter.eegplot

% Description: Sets a black background
% Documentation: class_plotter_eegplot.txt

import plotter.rnd_colors;
import misc.process_arguments;

opt.MinDist         = 0;
opt.MinLuminance    = 0.1;
opt.ForeColor       = [1 1 1];
opt.AxesColor       = [];
[~, opt] = process_arguments(opt, varargin);

if ~isnumeric(opt.ForeColor) || numel(opt.ForeColor) ~= 3 || ...
        any(opt.ForeColor > 1) || any(opt.ForeColor < 0),
    error('Argument ''ForeColor'' must be a RGB color specification');
end

if isempty(opt.AxesColor), opt.AxesColor = 0.8*opt.ForeColor; end

if ~isnumeric(opt.AxesColor) || numel(opt.AxesColor) ~= 3 || ...
        any(opt.AxesColor > 1) || any(opt.AxesColor < 0),
    error('Argument ''AxesColor'' must be a RGB color specification');
end

if prod(get(obj.Figure, 'Color')) < 0.001,
    % Figure already has a black background
    return;
end

newColors  =  rnd_colors(nb_plots(obj), 'Background', 'dark');

set_overlay_colors(obj, newColors);

set(obj.Figure, ...
    'Color', 'Black', ...
    'InvertHardCopy', 'off');

set(obj.AxesBg, 'Color', 'Black');

set_axes(obj, ...
    'XColor', opt.AxesColor, ...
    'YColor', opt.AxesColor);

set_scale_label(obj, ...
    'Color', opt.ForeColor);

set_scale_axes(obj, ...
    'Color', opt.ForeColor);

evColors =  get_event_color(obj);

if ~isempty(evColors),
    % If there are any event lines
    newEvColors = rnd_colors(size(evColors,1), ...
        'MinLuminance', opt.MinLuminance*2, ...
        'MinDist',      opt.MinDist, ...
        'InitGuess',    evColors);
    
    set_event_color(obj, [], newEvColors);
end



end