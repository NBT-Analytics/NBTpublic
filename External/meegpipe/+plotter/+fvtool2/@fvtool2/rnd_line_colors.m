function h = rnd_line_colors(h, varargin)
% RND_LINE_COLORS - Randomize filter line colors
%
% rnd_line_colors(h)
% rnd_line_colors(h, 'key', value, ...)
%
% ## Optional arguments (as key/value pairs):
%
%       MinDist: A numeric scalar in the range (0,1). Default: 0.1
%           Minimum Euclidean distance between two different line colors
%
%       MinLuminance: A numeric scalar in the range (0,1). Default: 0
%           Minimum color luminance
%
%       InitGuess: A Kx3 matrix with RGB color specifications. Default: []
%           A initial set of colors can be provided using this argument
%
%
% See also: plotter.psd

% Description:  Randomize PSD line colors
% Documentation: class_plotter_psd.txt

import plotter.process_arguments;
import exceptions.*;
import plotter.luminance;
import misc.euclidean_dist;

MAX_ITER = 100;

opt.MinDist         = 0.1;
opt.MinLuminance    = 0;
opt.InitGuess       = [];
[~, opt] = process_arguments(opt, varargin);

figH = h.FvtoolHandle;
origSelection = h.Selection;
for idx = 1:numel(origSelection)   
    
    ch = findall(figH(idx), 'Type', 'line', '-regexp',  'Tag', '_line');
    nLines = numel(ch);
    
    if isempty(opt.InitGuess),
        opt.InitGuess = rand(nLines, 3);
    end
    
    if ~isnumeric(opt.InitGuess) || ndims(opt.InitGuess) ~= 2  || ...
            size(opt.InitGuess, 2) ~= 3,
        throw(InvalidArgument('InitGuess', ...
            'Must be a Kx3 matrix of RGB color specifications'))
    end
    
    select(h, origSelection(idx));
    colors = [opt.InitGuess;rand(nLines-size(opt.InitGuess,1), 3)];
    for i = 1:size(colors, 1),
        count = 0;
      
        while luminance(colors(i,:)) < opt.MinDist && ...
                i>1 && any(euclidean_dist(colors(i,:), colors(1:i-1,:)) < ...
                opt.MinDist) && count > MAX_ITER,
            colors(i, :) = rand(1,3);
            count = count + 1;
        end
  
        set_line(h, i, 'Color', colors(i, :));
    end
    
end

select(h, origSelection);

end