function hc = clone(h)
% CLONE - Creates a clone of a plotter.psd.psd figure
%
% hc = clone(h)
%
% Where
%
% H is a plotter.psd.psd figure handle
%
% HC is a plotter.psd.psd handle to a new figure, identical to the figure
% handled by H
%+
% See also: plotter.psd.psd


import plotter.get_ch_handles;

hc = plotter.psd.psd(get_config(h));

if isempty(h.Figure),
    return;
end

visible = get_config(hc, 'Visible');
if visible, visible = 'on'; else visible = 'off'; end

hc.Figure       = figure('Visible', visible);
hc.Name         = h.Name;
hc.LegendProps  = h.LegendProps;
hc.Data         = h.Data;
hc.Frequencies  = h.Frequencies;

% Create a copy of the figure
copyobj(get(h.Figure, 'Children'), hc.Figure);

% Now attach a plotter.psd.psd handle to the new figure
origH = get_ch_handles(h.Figure);
newH  = get_ch_handles(hc.Figure);

if ~isempty(newH) && ~isempty(origH) && ~isempty(h.Axes),
    hc.Axes = newH(origH == h.Axes);
end

hc.Line = h.Line;
for i = 1:size(hc.Line,1)
    % Is this robust enough? Can we trust the intuition that the order of
    % the handles returned by get_ch_handles on both the original and cloned
    % figure remains the same?
    hc.Line{i,1} = newH(origH == h.Line{i,1});
    %hc.Line{i,1} = findobj(newH, );
    if ~isempty(hc.Line{i,2}),
        hc.Line{i,2}    = newH(origH == h.Line{i,2});
        hc.Line{i,3}(1) = newH(origH == h.Line{i,3}(1));
        hc.Line{i,3}(2) = newH(origH == h.Line{i,3}(2));
    end
end

if ~isempty(h.Legend) && ~isempty(origH),
    hc.Legend = newH(origH == h.Legend);
end


end