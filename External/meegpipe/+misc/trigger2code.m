function [sample, code] = trigger2code(trigger, varargin)
% TRIGGER2CODE - Converts a trigger channel into an array of trigger codes
%
%   [sample, code] = trigger2code(trigger)
%   [sample, code] = trigger2code(trigger, 'key', value, ...)
%
% Where
%
% TRIGGER is the trigger channel
% 
% SAMPLE is an array of sample numbers
%
% CODE is an array of trigger codes
%
%
% ## Accepted key/value pairs:
%
%   MinDuration   <value/samples>
%                 Minimum duration of a trigger pulse. If a pulse of a 
%                 shorter duration it will be ignored.
%
%
% See also: misc

import misc.process_arguments;

opt.minduration = 1;
[~, opt] = process_arguments(opt, varargin);

trigger = trigger(:);

% Places where the triggers start
triggerStart = find([trigger(1);abs(diff(trigger))>0]);
triggerEnd   = triggerStart(abs(trigger(triggerStart))<eps);

if isempty(triggerStart) || isempty(triggerEnd),
    sample = [];
    code = [];
    return;
end
triggerStart = setdiff(triggerStart, triggerEnd);
tmp = [0;trigger];
alsoEnd = triggerStart(abs(tmp(triggerStart-1))>eps);
tmp = [trigger;trigger(end)];
alsoEnd2 = triggerStart(tmp(triggerStart+1) ~= tmp(triggerStart));
triggerEnd   = sort([triggerEnd;unique([alsoEnd;alsoEnd2])]);
triggerEnd   = triggerEnd-1;

% Crapy workaround for a problem observed sometimes
triggerEnd([diff(triggerEnd);Inf] < opt.minduration) = [];
triggerStart([diff(triggerStart);Inf] < opt.minduration) = [];

duration = triggerEnd - triggerStart;
sample = triggerStart(duration > opt.minduration);
code = trigger(sample);


end