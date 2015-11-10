function ev = from_eeglab(str)
% FROM_EEGLAB - Construction from EEGLAB structure
%
% evArray = from_eeglab(str)
%
% Where
%
% STR is an array of EEGLAB event structures, i.e. the array stored in
% field 'event' of an EEGLAB's dataset (EEG) structure. 
%
% EVARRAY is an equivalent array of event objects
%
% See also: from_fieldtrip, from_struct


import physioset.event.event;

if isempty(str), ev = []; return; end

evPos = [str.latency];
evType = {str.type};

% IMPORTANT: EEGLAB's events property "latency" stores the position of an 
% event in samples (pnts) relative to the beginning of the continuous data
% matrix (EEG.data). However, such "latency" property may take non-integer
% values. On the other hand meegpipe accepts only integer-value event
% positions (in samples). 
evPos = ceil(evPos);
ev = physioset.event.event(evPos);

for i = 1:numel(ev),
    if strcmpi(evType{i}, 'boundary'),
        ev(i) = physioset.event.std.discontinuity(evPos(i));
    else
        ev(i) = event.from_struct(str(i));
    end
end


end
