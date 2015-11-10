function obj = plot(obj, psdObj, varargin)
% PLOT - Plots a Power Spectral Density (PSD) estimate
%
% plot(h, psd)
% plot(h, psd, lineSpecs)
%
% Where
%
% H is a plotter.psd.psd handle
%
% PSD is a Power Spectral Density estimate object, as generated for
% instance by spectrum.psd
%
% LINESPECS are the the plotting specifications for the PSD line. See help
% plot for more information on valid line specifications.
%
% ## Example:
%
% % Create a sample PSD
% x = randn(1, 1000);
% estimatorObj = spectrum.welch;
% psdX = psd(estimatorObj, x);
%
% % Plot it using the default plotter
% plot(psdX);
%
% % Plot it using plotter.psd.psd and get a handle to the resulting plot
% figure;
% h = plot(plotter.psd.psd, psdX);
%
% % Let's plot a second PSD (with Conf. Intervals), using a red color
% y = .5*rand(1, 1000);
% psdY = psd(estimatorObj, y, 'ConfLevel', .98);
% plot(h, psdY, 'r');
%
% % Change the thickness of the main PSD lines
% set_line(h, [], 'LineWidth', 3);
%
% % Change the names of the PSDs i.e. the legend's text
% set_psdname(h, 1:2, {'randn', '.5*rand'})
%
% % Make the plots transparent
% h.Transparent = true
%
% % Hide the legend
% set_legend(h, 'Visible', 'off')
%
%
% See also: spectrum.psd, plotter.psd.psd

import plotter.psd.psd;
import exceptions.*;

if nargin < 2 || ~isa(psdObj, 'dspdata.psd'),
    throw(InvalidArgument('psdObj', ...
        'A dspdata.psd object was expected'));
end

% Configuration options
visible         = get_config(obj, 'Visible');

if visible, visible = 'on'; else visible = 'off'; end

% Create a new figure, maybe a invisible one
if ~isempty(obj.Figure),
    set(0, 'CurrentFigure', obj.Figure);
else
    obj.Figure = figure('Visible', visible);
end

if ~isempty(obj.Axes),
    set(obj.Figure, 'CurrentAxes', obj.Axes);
end

% Deal with the case of multiple PSD objects provided at input
count = 1;
dataArray = repmat(dspdata.psd, 1, numel(varargin));
while count <= numel(varargin) && isa(varargin{count}, 'dspdata.psd'),
    dataArray(count) = varargin{count};
    count = count + 1;
end

dataArray(count:end) = [];
varargin = varargin(count:end);

if ~isempty(dataArray),
    
    obj = plot(obj, psdObj, varargin{:});
    
    for i = 1:numel(dataArray)
        obj = plot(obj, dataArray(i), varargin{:});
    end    
   
    rnd_line_colors(obj);
    
    return;
    
end

if ~isempty(obj.Data),
    if any(size(obj.Data(1).Frequencies) ~= size(psdObj.Frequencies)) || ...
            any(obj.Data(1).Frequencies ~= psdObj.Frequencies),
        throw(psd.InconsistentPSD('Frequencies don''t match'));
    end
end

if ischar(psdObj.Fs) && strcmpi(psdObj.Fs, 'Normalized'),
    freqs = psdObj.Frequencies/pi;
else
    freqs = psdObj.Frequencies;
end

if isempty(obj.Frequencies),
    obj.Frequencies = freqs;
end

if ~isempty(psdObj.ConfInterval) && get_config(obj, 'ConfInt'),
    
    plot_conf(obj, psdObj, varargin{:});
    
else
    
    if ~isempty(obj.Figure),
        set(0, 'CurrentFigure', obj.Figure);
    end
    if ~isempty(obj.Axes),
        set(obj.Figure, 'CurrentAxes', obj.Axes);
    end
    
    % This is the first PSD: plot the axes   
    h           = plot(psdObj);
    obj.Axes    = gca;
    obj.Figure  = gcf;
      
    % If there was a previous legend, then it's gone now...
    obj.Legend  = [];
    hold on;
    delete(h);
    
    if get_config(obj, 'LogData')
        h = plot(obj.Axes, freqs, 10*log10(psdObj.Data), ...
            varargin{:});
    else
        h = plot(obj.Axes, freqs, psdObj.Data, ...
            varargin{:});
    end
    
    obj.Line = [obj.Line; {h, [], []}];
    obj.Name = [obj.Name; {psdObj.Name, []}];
    obj.Data = [obj.Data; psdObj];
    
    if ~get_config(obj, 'LogData'),
        axis tight;
        set_ylabel(obj);
    end
    
end

plot_legend(obj);

set_freq_limits(obj, get_config(obj, 'FrequencyRange'));

set_data_scale(obj);

match_scale(obj);

set_boi(obj);

end

