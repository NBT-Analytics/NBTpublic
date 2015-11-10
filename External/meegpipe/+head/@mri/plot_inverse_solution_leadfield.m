function h = plot_inverse_solution_leadfield(obj, varargin)
% PLOT_INVERSE_SOLUTION_LEADFIELD
% Plots the leadfield of the inverse solution
%
% plot_inverse_solution_leadfield(obj)
%
% plot_inverse_solution_leadfield(obj, 'key', value, ...)
%
%
% where
%
% OBJ is a head.mri object
%
% 
% ## Accepted key/value pairs:
%
% All key/value pairs accepted by method plot_source_leadfield()
%
%
% ## Notes:
%
% * This method is an alias of method plot_source_leadfield(). That is, the
%   call:
%
%   plot_inverse_solution_leadfield(obj, 'key', value, ...)
%
%   is equivalent to calling:
%
%   plot_source_leadfield(obj, 'InverseSolution', true, 'key', value, ...)
%
%   
%
% See also: head.mri.plot_source_leadfield

h = plot_source_leadfield(obj, 1, 'InverseSolution', true, varargin{:});



end