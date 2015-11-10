function obj = from_eeglab(str)
% FROM_EEGLAB - Constructor from EEGLAB chanlocs structure
%
% obj = from_eeglab(str)
%
% Where
%
% STR is the chanlocs field of an EEGLAB EEG struct.
%
% OBJ is an equivalent sensor.physiology object.
%
% See also: from_fieldtrip

import sensors.*;

if isfield(str, 'grad'),
    obj = meg.from_eeglab(str);
elseif isfield(str, 'pnt'),
    obj = eeg.from_eeglab(str);
else    
    obj = sensors.physiology('Label', {str.labels});
end



end