function y = gca_lims

ah = get(gcf, 'CurrentAxes');
if isempty(ah),
    y = [];
    return;
end

xrange = get(ah, 'XLim');
yrange = get(ah, 'YLim');
zrange = get(ah, 'ZLim');

y = [xrange, yrange, zrange];

end