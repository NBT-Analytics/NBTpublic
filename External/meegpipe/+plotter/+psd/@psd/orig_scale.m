function obj = orig_scale(obj)
% ORIG_SCALE - Plots PSD using their original scaling
%
% orig_scale(h)
%
% Where
%
% H is a plotter.psd handle
%
%
% See also: match_scale, plotter.psd

% Description: Use original PSD scaling
% Documentation: class_plotter_psd.txt


for i = 1:numel(obj.Data)    
    yData = 10*log10(obj.Data(i).Data);
    prevYData = get(obj.Line{i,1}, 'YData');
    set(obj.Line{i,1}, 'YData', yData);    
    
    if isempty(obj.Line{i,2}), continue; end
    factor = yData'/prevYData;
    yData = get(obj.Line{i,2}, 'YData');
    set(obj.Line{i, 2}, 'YData', factor*yData);
    yData = get(obj.Line{i,3}(1), 'YData');
    set(obj.Line{i, 3}(1), 'YData', factor*yData);
    yData = get(obj.Line{i,3}(2), 'YData');
    set(obj.Line{i, 3}(2), 'YData', factor*yData);    
end

set_config(obj, 'MatchScale', []);


end