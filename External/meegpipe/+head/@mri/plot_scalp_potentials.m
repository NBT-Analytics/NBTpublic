function h = plot_scalp_potentials(obj, varargin)
% PLOT_SCALP_POTENTIALS
% Plots the generated scalp potentials
%
%
% plot_scalp_potentials(obj, 'key', value, ...)
%
%
% where
%
% OBJ is a head.mri object
%
%
% ## Accepted key/value pairs:
%
% 'Time'    : A numeric array specifying the sampling instants at which the
%             corresponding potentials should be plotted. If multiple time
%             instants are provided the result will be a 2D or 3D
%             topographic plot of scalp potentials. If not provided or
%             empty, all time instants will be plotted as a stacked
%             time-series plot. Default: []
%
% 'Topo'    : Type of topographic display. Either '2D' or '3D'. This
%             argument is only relevant if the Time argument is not
%             provided. Default: '2D'
%
% 'Output'  : Either 'figures', 'png' or 'pdf'. The 'figures' option (the
%             default) will generate a series of MATLAB figures. The 'png'
%             option will create a .png graphics file for each topography.
%             The 'pdf' option will create an animated pdf file (a video).
%             The latter option is only available if pdflatex is installed
%             in the system. Default: 'figures'
%
%
%
% See also: head.mri

% Documentation: class_head_mri.txt
% Description: Plots scalp potentials

import misc.process_varargin;

keySet = {'time', 'topo', 'output', 'samplingrate'};
time = [];
eval(process_varargin(keySet, varargin));

if isempty(time),
    % Time-series plot
    data = scalp_potentials(obj);
    eegplot(data, 'srate', srate);
else
    % Topographic plot
    h = plot_source_leadfield(obj, 1:obj.NbSources, varargin{:}, ...
        'Leadfield', scalp_potentials(obj, 'Time', time)); 
end




end