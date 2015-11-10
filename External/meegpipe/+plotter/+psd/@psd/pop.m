function obj = pop(obj)
% POP - Deletes the last PSD
%
% pop(h)
%
% Where
%
% H is a plotter.psd handle
%
% See also: delete, plotter.psd

% Description: Delete the last PSD
% Documentation: class_plotter_psd.txt


delete_psd(obj, numel(obj.Data));

end