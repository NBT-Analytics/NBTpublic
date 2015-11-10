function obj = from_fieldtrip(elec, label)
% FROM_FIELDTRIP - Construction from field elec of a Fieldtrip structure
%
% obj = sensors.eeg.from_fieldtrip(elec, label)
%
% Where
%
% elec is a Fieldtrip struct with EEG electrodes/channels information, i.e.
% the contents of field 'elec' of a standard Fieldtrip dataset structure.
%
% LABEL are the labels of the used sensors. i.e. the contents of the field
% 'label'of a standard Fieldtrip dataset structure. This second input
% arguments is required whenever a Fieldtrip dataset contains data from a
% sub-set of the sensors.described in field 'elec'.
%
% OBJ is the generated sensors.eeg object
%
% See also: from_eeglab, from_file


import mjava.hash;

if ~isstruct(elec) || ~isfield(elec, 'label'),
    ME = MException('from_fieldtrip:InvalidInput', ...
        'The input argument is not a valid Fieldtrip struct');
    throw(ME);
end

if nargin < 2 || isempty(label),
    label = elec.label;
end

[isValid, selection] = ismember(label, elec.label);

if ~all(isValid),
    ME = MException('sensors.eeg:from_fieldtrip:InvalidElec', ...
        'The electrode labels are not consistent with the data channel labels');
    throw(ME);
end

if isfield(elec, 'chanpos'),
    chanpos = elec.chanpos;
else
    chanpos = [];
end

if isfield(elec, 'elecpos'),
    % New Fieldtrip format
    coords = elec.elecpos(selection, :);
elseif isfield(elec, 'pnt'),
    % Old Fieldtrip format
    coords = elec.pnt(selection, :);
else
    % No channel position information
    coords = []; 
end

% Find fiducials
isFid = cellfun(@(x) ~isempty(regexpi(x, '^fid')), elec.label);
if any(isFid),
    fidLabels = elec.label(isFid);
    fidCoords = elec.elecpos(isFid,:);
    fiducials = hash;
    fiducials{fidLabels{:}} = mat2cell(fidCoords, ones(numel(fidLabels),1), 3);
else
    fiducials = [];
end

obj = sensors.eeg(...
    'Cartesian',    coords, ...
    'Label',        elec.label(selection), ...
    'OrigLabel',    elec.label(selection), ...
    'Fiducials',    fiducials);

if ~isempty(chanpos),
    obj = set_meta(obj, 'chanpos', chanpos);
end

% Makes things easier when converting back to Fieldtrip format
obj = set_meta(obj, 'Fieldtrip_elec', elec);


end