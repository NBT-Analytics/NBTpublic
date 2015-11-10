function elec = fieldtrip(obj)
% FIELDTRIP - Converts a sensors.eeg object to a Fieldtrip "elec" structure
%
% elec = fieldtrip(obj)
%
% See also: eeglab, sensors.eeg


elec = get_meta(obj, 'Fieldtrip_elec');
if isempty(elec),
    elec.elecpos = obj.Cartesian;
    elec.label   = orig_labels(obj);
    elec.chanpos = obj.Cartesian;
end

end