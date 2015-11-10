function y = reshape(obj, varargin)

s.type = '()';
s.subs = {1:size(obj,1), 1:size(obj,2)};
y = reshape(subsref(obj, s), varargin{:});