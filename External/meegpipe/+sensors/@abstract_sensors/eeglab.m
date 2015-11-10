function outStr = eeglab(obj)
% EEGLAB - Converts to an EEGLAB-compatible structure
%
% str = eeglab(obj)
%
% where
%
% OBJ is a sensors.physiology object
%
% STR is a struct array that complies with EEGLAB's conventions
%
%
% See also: sensors.physiology

% Documentation: class_sensors.physiology.txt
% Description: Conversion to EEGLAB structure

if nb_sensors(obj) < 1,
    outStr = [];
    return;
end

labelArray = orig_labels(obj);

if isempty(labelArray),
    labelArray = labels(obj);
end

if isempty(labelArray),
    labelArray = split(char(10), num2str((1:nb_sensors(obj))'));
end

outStr = cell2struct(cell(1,11), ...
    {'X','Y','Z', 'labels', 'sph_theta', 'sph_phi', 'sph_radius', ...
    'theta', 'radius', 'sph_theta_besa', 'sph_phi_besa'},2);

outStr = repmat(outStr, numel(labelArray), 1);

for i = 1:nb_sensors(obj)
    outStr(i).labels = labelArray{i};
end