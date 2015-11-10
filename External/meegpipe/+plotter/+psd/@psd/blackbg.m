function h = blackbg(h, varargin)
% BLACKBG - Sets a black background for a plotter.psd figure
%
% blackbg(h)
% blackbg(h, 'ForeColor', [0.7 0.7 0.7])
%
%
% Where
%
% H is a plotter.psd handle
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
%
% See also: plotter.psd

% Description: Sets a black background
% Documentation: class_plotter_psd.txt

import plotter.process_arguments;
import plotter.euclidean_dist;
import plotter.process_arguments;


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

if prod(get(h.Figure, 'Color')) < 0.001,
    % Figure already has a black background
   return; 
end

set(h.Figure, ...
        'Color', 'Black', ...
        'InvertHardCopy', 'off');    
    
set_axes(h, ...
    'Color', 'Black', ...
    'XColor', opt.AxesColor, ...
    'YColor', opt.AxesColor);

set_legend(h, ...
    'TextColor',    opt.ForeColor, ...
    'Color',        'Black', ...
    'EdgeColor',    opt.ForeColor);
set_xlabel(h,   'Color', opt.ForeColor);
set_ylabel(h,   'Color', opt.ForeColor);
set_title(h,    'Color', opt.ForeColor);

rnd_line_colors(h);    


% If the plot if transparent, we need to increase the alpha value to make
% the shadows visible
currPatchSaturation = get_config(h, 'PatchSaturation');
set_config(h, 'PatchSaturation',  min(0.7, currPatchSaturation*2.75));


end