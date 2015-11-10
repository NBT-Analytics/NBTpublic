function h = set_legend(h, varargin)
% SET_LEGEND - Set legend properties
%
% set_legend(h, propName, propValue)
%
% Where
%
% H is a plotter.psd handle
%
% PROPNAME is the name of a valid legend property
%
% PROPVALUE is the value to be given to the specified legend property
%
% See also: get_legend, plotter.psd

% Description: Set legend property values
% Documentation: class_plotter_psd.txt

% For some reason this does not work always and that is why we re-plot the
% whole legend anytime that a property is changed.
%set(h.Legend, varargin{:});

if isempty(h.LegendProps),
    h.LegendProps = struct(varargin{:});
else
    count = 1;
    while count < numel(varargin)
        h.LegendProps.(varargin{count}) = varargin{count+1};
        count = count + 2;
    end
end

plot_legend(h);

end