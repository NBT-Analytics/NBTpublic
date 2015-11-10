function plot_conf(obj, psdObj, varargin)

import shadederrorbar.shadedErrorBar;

y           = 10*log10(psdObj.Data');
confInt     = 10*log10(psdObj.ConfInterval');
errBar(1,:) = confInt(2,:) - y;
errBar(2,:) = y - confInt(1,:);

if ~isempty(obj.Figure),
    set(0, 'CurrentFigure', obj.Figure);
end
if ~isempty(obj.Axes),
    set(obj.Figure, 'CurrentAxes', obj.Axes); 
end

h = plot(psdObj);
if isempty(obj.Axes),
    obj.Axes    = gca;
end
if isempty(obj.Figure),
    obj.Figure  = gcf;
end

% If there was a previous legend, then it's gone now...
obj.Legend  = [];
hold on;
delete(h);

if ischar(psdObj.Fs) && strcmpi(psdObj.Fs, 'Normalized'),
    freqs = psdObj.Frequencies/pi;
else
    freqs = psdObj.Frequencies;
end

if get_config(obj, 'LogData'),
    data = 10*log10(psdObj.Data);
else
    data = psdObj.Data;
end

H = shadedErrorBar(...
    freqs, ...
    data, ...
    errBar, ...
    varargin, get_config(obj, 'Transparent'));

if isnumeric(psdObj.ConfLevel),
    confIntLegend = sprintf('%d %% Confidence Interval', ...
        round(psdObj.ConfLevel*100));
else
    confIntLegend = psdObj.ConfLevel;
end

obj.Line  = [obj.Line; {H.mainLine, H.patch, H.edge}];
obj.Name  = [...
    obj.Name; ...
    {psdObj.Name,  confIntLegend}...
    ];

obj.Data = [obj.Data; psdObj];

end