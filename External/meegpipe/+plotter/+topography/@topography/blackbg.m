function h = blackbg(h, varargin)
% BLACKBG - Sets a black bakcground for a plotter.psd figure
%
% blackbg(h)
% blackbg(h, 'ForeColor', [0.7 0.7 0.7])
%
%
% Where
%
% H is a plotter.scalp_topo handle
%
% IDX is the index of the figure to be cloned. If IDX is not provided or is
% empty, all fvtool2 figures will be cloned. IDX can also be an array of
% figure indices. 
%
% ## Optional key/value pairs:
%
% You can specify optional arguments as key/value pairs (see second and
% third example in the usage synopsis above).
%
%       ForeColor:  A 1x3 numeric array. Default: [1 1 1], i.e. white
%           Defines the foreground color for the figure.
%
%       MinDist: A numeric scalar in the range (0,1). Default: 0.1
%           Minimum Euclidean distance between two different line colors
%   
%       MinLuminance: A numeric scalar in the range (0,1). Default: 0
%           Minimum color luminance
%
%       InitGuess: A Kx3 matrix with RGB color specifications. Default: []
%           A initial set of colors can be provided using this arg
%
%
% See also: plotter.psd

% Description: Sets a black background
% Documentation: class_plotter_psd.txt

import plotter.process_arguments;
import plotter.euclidean_dist;
import plotter.process_arguments;

opt.MinDist         = 0.1;
opt.MinLuminance    = 0.1;
opt.InitGuess       = [];
opt.ForeColor       = [1 1 1];
[~, opt] = process_arguments(opt, varargin);

if ~isnumeric(opt.ForeColor) || numel(opt.ForeColor) ~= 3 || ...
        any(opt.ForeColor > 1) || any(opt.ForeColor < 0),
    error('Argument ''ForeColor'' must be a RGB color specification');
end

if prod(get(h.Figure, 'Color')) < 0.001,
   return; 
end

set(h.Figure, ...
        'Color', 'Black', ...
        'InvertHardCopy', 'off'); 
set(h.Rim, 'FaceColor', 'Black');
%set(h.ContourLines, 'LineColor', 'white');
set(h.ContourLines, 'LineWidth', 1.5*get(h.ContourLines, 'LineWidth'));
set_contour_surface(h, 'EdgeAlpha', 0);



end