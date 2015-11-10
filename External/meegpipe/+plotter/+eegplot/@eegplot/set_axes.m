function h = set_axes(h, varargin)
% SET_AXES - Set Axes properties
%
% set_axes(h, 'propName', propValue)
%
% See also: get_axes


if ~isempty(h.Axes),
    set(h.Axes, varargin{:});
end


end