function dist = euclidean_dist(obj)
% EUCLIDEAN_DIST - Euclidean distance between EEG sensors.
%
% dist = euclidean_dist(obj)
%
%
% Where
%
% OBJ is a sensors.eeg object containing the especifications of K sensors.
%
% DIST is a KxK matrix with the Euclidean distances between each pair of
% sensors.
%
%
% See also: sensors.eeg

import misc.euclidean_dist;

dist = nan(obj.NbSensors);
for i = 1:obj.NbSensors
    dist(:, i) = euclidean_dist(obj.Cartesian(i,:), obj.Cartesian);
end



end