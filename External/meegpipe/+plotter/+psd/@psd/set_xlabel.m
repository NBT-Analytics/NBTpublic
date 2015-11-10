function h = set_xlabel(h, varargin)
% SET_XLABEL - Set title property values
%
% set_xlabel(h, propName, propValue)
%
%
% See also: get_xlabel


if isempty(h.Axes), return; end

xlabelH = get(h.Axes, 'XLabel');

if isempty(xlabelH), 
    error('I can''t set properties of a non-existent X-axis label');
end

set(xlabelH, varargin{:});




end