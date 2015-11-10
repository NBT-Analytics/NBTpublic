function [y, obj] = filtfilt(obj, data, varargin)

y = data;
for i = 1:numel(obj.Filter)
    y = filtfilt(obj.Filter{i}, y, varargin{:});
end



end