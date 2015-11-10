function obj = from_fieldtrip(grad, label)
% FROM_FIELDTRIP - Construction from field grad of a Fieldtrip structure
%
% obj = sensors.meg.from_fieldtrip(grad, label)
%
% Where
%
% GRAD is a Fieldtrip struct with EEG channels information, i.e.
% the contents of field 'grad' of a standard Fieldtrip dataset structure.
%
% LABEL are the labels of the used sensors. i.e. the contents of the field
% 'label'of a standard Fieldtrip dataset structure. This second input
% arguments is required whenever a Fieldtrip dataset contains data from a
% sub-set of the sensors.described in field 'grad'.
%
% OBJ is the generated sensors.meg object
%
% See also: from_eeglab, from_file


import mjava.hash;

if ~isstruct(grad) || (~isfield(grad, 'chanori') && ~isfield(grad, 'chanpos')),
    ME = MException('sensors:meg:from_fieldtrip:InvalidInput', ...
        'Input is not a valid Fieldtrip struct with channel information');
    throw(ME);
end

if nargin < 2 || isempty(label),
    label = grad.label;
end

[isValid, selection] = ismember(label, grad.label);

if ~all(isValid),
    ME = MException('sensors.meg:from_fieldtrip:InvalidElec', ...
        'Sensor labels are not consistent with the data channel labels');
    throw(ME);
end

% Extra "sensors.
if numel(selection) ~= numel(grad.label),
    idx = setdiff(1:numel(grad.label), selection);
    extraLabels = grad.label(idx);
    extraCoords = grad.chanpos(idx, :);    
    extra = hash;
    extra{extraLabels{:}} = mat2cell(extraCoords, ...
        ones(numel(extraLabels),1), 3);
else
    extra = [];
end

coilArray = sensors.coils(...
    'Cartesian',    grad.coilpos, ...
    'Orientation',  grad.coilori, ...
    'Weights',      grad.tra(selection,:));

obj = sensors.meg(...
    'Cartesian',    grad.chanpos(selection, :), ...
    'Unit',         grad.unit, ...
    'Label',        grad.label(selection), ...
    'OrigLabel',    grad.label(selection), ...
    'Coils',        coilArray, ...
    'Extra',        extra);
    
% Makes things easier when converting back to Fieldtrip format
obj = set(obj, 'Fieldtrip_grad', grad);

end