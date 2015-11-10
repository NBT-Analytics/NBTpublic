function [y, idx] = sort(x, varargin)


[~, idx] = sort(cell2mat(get_sample(x)), varargin{:});
y = x(idx);

end