function obj = from_fieldtrip(hdr)

import sensors.*;

if isfield(hdr, 'grad'),
    obj = meg.from_fieldtrip(hdr);
elseif isfield(hdr, 'pnt'),
    obj = eeg.from_fieldtrip(hdr);
elseif isfield(hdr, 'label'),
    obj = sensors.physiology('Label', hdr.label);
else
    error('Not implemented yet!');
end

end