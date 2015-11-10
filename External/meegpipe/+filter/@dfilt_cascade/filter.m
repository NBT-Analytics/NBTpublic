function [y, obj] = filter(obj, data, varargin)

y = data;
for i = 1:numel(obj.Filter)
    y = filter(obj.Filter{i}, y, varargin{:});
end



end