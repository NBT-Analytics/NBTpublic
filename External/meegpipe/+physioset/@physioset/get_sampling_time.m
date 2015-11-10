function [value, absTime] = get_sampling_time(obj, idx)
% get_sampling_time - Sampling times for physioset samples
%
% ## Usage
%
% ````matlab
% time = get_sampling_time(obj);
% timeSet = get_sampling_time(obj, idx);
% [time, absTime] = get_sampling_time(obj);
% [timeSet, absTimeSet] = get_sampling_time(obj, idx);
% ````
%
% Where
%
% `obj` is a `physioset` object and `idx` is a set of sampling instant
% indices.
%
% `time` is a vector of relative sampling times (in seconds). The time
% origin of physioset `obj` can be retrieved using:
%
% ````matlab
% timeOrig = get_time_origin(obj);
% ````
%
% `timeSet` is the relative sampling instant for the sample with indices in
% the set `idx`.
%
% `absTime` is a vector of absolute sampling instants and `absTimeSet` is
% the `i`th element of such vector, i.e. the absolute sampling instant for
% the `i`th sample. Notice that:
%
% ````matlab
% % For any i being a scalar in the range 1:size(obj,2)
% [timei, absTimei] = get_sampling_time(obj, i);
% timeOrig = get_time_origin(obj);
% assert(absTimei == addtodate(timeOrig, round(timei*1000), 'millisecond'));
% ````
%
% See also: physioset

if nargin < 2 || isempty(idx),
    idx = 1:size(obj, 2);
end

if isempty(obj.PntSelection),
    value = obj.SamplingTime;
else
    value = obj.SamplingTime(obj.PntSelection);
end

value = value(idx);

if isempty(value),
    absTime = [];
else
    msPerDay = 24*60*60*1000;
    absTime = get_time_origin(obj) + round(value*1000)/msPerDay;
end

end