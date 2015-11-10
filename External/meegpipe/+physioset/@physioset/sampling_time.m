function [value, absTime] = sampling_time(obj)
% sampling_time - Sampling times for physioset samples
%
% This method has been deprecated in favor of method get_sampling_time. It
% is maintained simply for backwards compatibility purposes.
%
% See also: physioset

[value, absTime] = get_sampling_time(obj, 1:size(obj,2));

end