function h = set_edges(h, idx, varargin)
% SET_EDGES - Sets properties of a PSD's shadow edges (conf. interval)
%
% h = set_egdes(h, idx, 'Prop1', val1, 'Prop2', val2, ...)
%
% Where
%
% H is a plotter.psd handle
%
% IDX is the index of the PSD whose properties are to be modified.
% Alternatively, IDX can be the "Name" of a PSD. Valid PSD names are listed
% in property PSDName of object H. 
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
%
% See also: set_line, set_edges, set_psdname, get_shadow, plotter.psd

% Documentation: class_plotter_psd.txt
% Description: Set PSD shadow edges properties


if nargin < 2,
    return;
end

idx = resolve_idx(h, idx);

for i = 1:numel(idx)
   set(h.Line{idx(i),3}, varargin{:}); 
end


end