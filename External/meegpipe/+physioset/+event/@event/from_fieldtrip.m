function ev = from_fieldtrip(str)
% FROM_FIELDTRIP - Construction from Fieldtrip structure
%
% evArray = from_fieldtrip(str)
%
% Where
%
% STR is an array of Fieldtrip event structures, i.e. the array stored in
% field 'event' of an EEGLAB's dataset (EEG) structure. 
%
% EVARRAY is an equivalent array of event objects
%
% See also: from_fieldtrip, from_struct


import physioset.event.event;

ev = event.from_struct(str);

end

