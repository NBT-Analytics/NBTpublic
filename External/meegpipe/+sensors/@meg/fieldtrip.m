function grad = fieldtrip(obj)
% FIELDTRIP - Converts a sensors.meg object to a Fieldtrip "grad" structure
%
% str = fieldtrip(obj)
%
% See also: eeglab, sensors.meg


grad = get_meta(obj, 'Fieldtrip_grad');
if isempty(grad),
    grad.chanpos = obj.Cartesian;
    grad.unit    = obj.PhysDim;
    grad.label   = orig_labels(obj);
end

end