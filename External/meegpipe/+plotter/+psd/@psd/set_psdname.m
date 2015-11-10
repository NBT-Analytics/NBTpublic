function h = set_psdname(h, idx, name)
% SET_PSDNAME - Sets name of a PSD
%
% h = set_psdname(h, idx, name)
%
% Where
%
% H is a plotter.psd handle
%
% IDX is the index of the PSD whose name is to be modified.
% Alternatively, IDX can directly be the name of the PSD that is to be 
% modified. Valid PSD names are listed in property PSDName of object H. 
%
% NAME is a string or a cell array of strings with the new PSD name(s).
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
% % Change the name of the PSDs to something more meaninful
% set_psdname(hp, 1, 'Gray PSD');
% set_psdname(hp, 2, 'Red PSD');
%
% % Change the names to something else
% set_psdname(hp, 1:2, {'First PSD', 'Second PSD'});
%
% See also: set_line, set_edges, plotter.psd

% Documentation: class_plotter_psd.txt
% Description: Set PSD(s) name(s)

if nargin < 2,
    return;
end

idx = resolve_idx(h, idx);

if ~iscell(name),
    name = {name};
end

for i = 1:numel(idx)
   h.Name{idx(i),1} = name{i};
end

plot_legend(h);


end