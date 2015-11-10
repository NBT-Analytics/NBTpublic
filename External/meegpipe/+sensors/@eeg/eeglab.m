function outStr = eeglab(obj, what)
% EEGLAB - Converts a sensors.eeg object to an EEGLAB-compatible structure
%
% str = eeglab(obj)
% str = eeglab(obj, what)
%
% where
%
% OBJ is a sensors.eeg object
%
% WHAT is string identifying what is to be converted to EEGLAB format,
% either 'sensors., 'fiducial' or 'extra'.
%
% STR is a struct array with sensor locations and labels, that complies
% with EEGLAB's standards
%
%
% See also: sensors.eeg


import sensors.abstract_sensors

if nargin < 2 || isempty(what),
    what = 'sensors';
end

if isempty(obj.Label), outStr = []; return; end

outStr = eeglab@sensors.physiology(obj);

radius    = head_radius(obj);

if strcmpi(what, 'sensors') && (isempty(obj.Cartesian) || ...
        all(isnan(obj.Cartesian(:)))),
    return;
elseif strcmpi(what, 'sensors')
    isMissing = any(isnan(obj.Cartesian),2);
    coords    = obj.Cartesian(~isMissing,:);   
    
    if ~isnan(radius),
        % EEGLAB expects a head radius of 0.5
        coords = coords.*(0.5/radius);
    end
    str = sensors.cart2eeglab(coords);
    fnames = setdiff(fieldnames(str), 'labels');
    sensLabels = orig_labels(obj);
    
    for j = 1:numel(str)
        for i = 1:numel(fnames)
            outStr(j).(fnames{i}) = str(j).(fnames{i});
        end
        outStr(j).labels = sensLabels{j};
    end
  
end

if strcmpi(what, 'fiducials') && isempty(obj.Fiducials),
    outStr = [];
elseif strcmpi(what, 'fiducials')
    labels = keys(obj.Fiducials)';
    coords = values(obj.Fiducials)';
    coords = cell2mat(coords);
    if ~isnan(radius),
        % EEGLAB expects a head radius of 0.5
        coords = coords.*(0.5/radius);
    end    
    outStr = sensors.cart2eeglab(coords);
    for i = 1:numel(outStr),
        outStr(i).labels = labels{i};
    end
end

if strcmpi(what, 'extra') && isempty(obj.Extra),
    outStr = [];
elseif strcmpi(what, 'extra')
    labels = keys(obj.Extra)';
    coords = values(obj.Extra)';
    coords = cell2mat(coords);
    if ~isnan(radius),
        % EEGLAB expects a head radius of 0.5
        coords = coords.*(0.5/radius);
    end    
    outStr = sensors.cart2eeglab(coords);
    for i = 1:numel(outStr),
        outStr(i).labels = labels{i};
    end
end

end