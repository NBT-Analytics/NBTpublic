function h = set_ylabel(h, varargin)
% SET_YLABEL - Set Y-axis label properties
%
% set_xlabel(h, propName, propValue)
%
%
% See also: get_ylabel



if isempty(h.Axes), return; end

ylabelH = get(h.Axes, 'YLabel');

if isempty(ylabelH), 
    error('I can''t set properties of a non-existent Y-axis label');
end

if nargin < 2,return; end

set(ylabelH, varargin{:});

end