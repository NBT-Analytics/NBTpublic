function radius = head_radius(obj)
% RADIUS - Rough estimate of the head radius
%
% radius = head_radius(obj)
%
% Where
%
% OBJ is a sensors.eeg object
%
% RADIUS is the estimated head radius (a scalar)
%
% See also: layout2d_radius

import sensors.abstract_sensors
import misc.process_arguments;

distance = @(x,y) misc.euclidean_dist(x,y);

specialLocs = {...
    'O1', ...
    'O2', ...
    'T5', ...
    'T6', ...
    'T3', ...
    'T4', ...
    'F7', ...
    'F8', ...
    'Fp1', ...
    'Fp2'};

radius = nan;
if isempty(obj),
    return;
end

extraPnt = obj.Extra;

if isempty(extraPnt),
    return;
end

coords = [];
for locItr = 1:numel(specialLocs)
    coords = [coords;extraPnt(specialLocs{locItr})];     %#ok<AGROW>
end

if isempty(coords) || size(coords,1) < 3
   return;
end

centerCoords = mean(coords);
radius = mean(distance(centerCoords, coords));


end