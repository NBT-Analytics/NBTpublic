function outStr = eeglab(obj)
% EEGLAB - Converts a sensors.meg object to an EEGLAB-compatible structure
%
% str = eeglab(obj)
%
% where
%
% OBJ is a sensors.meg object
%
% STR is a struct array with sensor locations and labels, that complies
% with EEGLAB's standards
%
%
% See also: sensors.meg

if isempty(obj.Cartesian), outStr = []; return; end


outStr = eeglab@sensors.physiology(obj);


isMissing = any(isnan(obj.Cartesian),2);

if all(isMissing), return; end

str = sensors.cart2eeglab(obj.Cartesian(~isMissing,:));

oneChan = str(1);
fnames = fieldnames(oneChan);
for i = 1:numel(fnames)
    oneChan.(fnames{i}) = [];
end

outStr = repmat(oneChan, nb_sensors(obj), 1);
outStr(~isMissing) = str;

origLabels = orig_labels(obj);

if ~isempty(origLabels),
    for i = 1:numel(outStr)
        outStr(i).labels = origLabels{i};
    end
end

end