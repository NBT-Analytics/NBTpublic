function obj = delete_psd(obj, idx)
% DELETE_PSD - Delete a PSD
%
% delete_psd(h, idx)
%
% Where
%
% H is a plotter.psd handle
%
% IDX is the index or indices of the PSD(s) that are to be deleted.
% Alternatively, IDX can be the name(s) of the relevant PSD(s). Valid PSD
% names are listed in property PSDName of object H. If IDX is empty, all
% PSDs will be deleted
%
% See also: pop, plotter.psd

% Description: Delete a PSD
% Documentation: class_plotter_psd.txt

idx = resolve_idx(obj, idx);

if numel(idx) > 1,
    for i = 1:numel(idx),
        delete(obj, idx(i));
    end
    return;
end


obj.Data(idx) = [];
delete(obj.Line{idx,1});
if ~isempty(obj.Line{idx,2}),
    delete(obj.Line{idx,2});
    delete(obj.Line{idx,3});
end
obj.Line(idx,:) = [];
obj.Name(idx,:) = [];

plot_legend(obj);

end