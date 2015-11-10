function value = get_edges(h, idx, varargin)
% GET_EDGES - Gets properties of a PSD's shadow edges (conf. interval)
%
% propVal = get_egdes(h, idx, propName)
%
% Where
%
% H is a plotter.psd handle
%
% IDX is the index of the PSD whose properties are to be modified.
% Alternatively, IDX can be the "Name" of a PSD. Valid PSD names are listed
% in property PSDName of object H. 
%
% PROPNAME is the name of the edges property whose value is requested.
%
% ## Examples:
%
% % Create a sample PSD plot
% h     = spectrum.welch;
% hpsd  = psd(h, randn(1,1000), 'Fs', 100, 'ConfLevel', 0.95);
% hp    = plot(plotter.psd, hpsd);
% hpsd2 = psd(h, 0.5*randn(1,1000), 'Fs', 100, 'ConfLevel', 0.9);
% plot(hp, hpsd2, 'r'); % Plot second PSD in red
%
% % Change the edges color and thickness for second PSD
% set_edges(hp, 2, 'LineWidth', 3, 'Color', 'green');
%
% % Get the value of the edges color (should return [0 1 0])
% get_edges(hp, 2, 'Color')
%
%
% See also: get_line, get_edges, get_psdname, set_edges, plotter.psd

% Documentation: class_plotter_psd.txt
% Description: Set PSD shadow edges properties


if nargin < 2,
    return;
end

idx = resolve_idx(h, idx);

value = cell(numel(idx),1);
for i = 1:numel(idx)
   if isempty(h.Line{idx(i),3}),
       continue;
   end
   value{i} = get(h.Line{idx(i),3}(1), varargin{:});    
end
if numel(value) == 1,
    value = value{1};
end



end