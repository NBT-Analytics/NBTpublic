function h = blackbg(h, varargin)
% BLACKBG - Sets a black bakcground for a fvtool2 figure
%
% blackbg(h)
%
%
%
% See also: plotter.fvtool2

% Description: Sets a black background
% Documentation: class_plotter_fvtool2.txt

import misc.process_arguments;

opt.MinDist         = 0.1;
opt.MinLuminance    = 0;
opt.InitGuess       = [];
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


origSelection = h.Selection;
for idx = 1:numel(origSelection)
    select(h, origSelection(idx));
    
    if prod(get_figure(h, 'Color')) < 0.001,
        continue;
    end
    
    set_figure(h,  ...
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
    set_xlabel(h, 'Color', opt.ForeColor);
    set_ylabel(h, 'Color', opt.ForeColor);
    set_title(h,  'Color', opt.ForeColor);
    
    % Avoid having lines with very low luminance
    rnd_line_colors(h, ...
        'MinLuminance', opt.MinLuminance, ...
        'MinDist',      opt.MinDist);
end
select(h, origSelection);

end