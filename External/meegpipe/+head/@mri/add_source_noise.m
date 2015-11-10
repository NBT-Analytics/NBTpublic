function obj = add_source_noise(obj, varargin)
% ADD_SOURCE_NOISE - Adds background noise at the source level
%
% 
% obj = add_source_noise(obj)
%
% obj = add_source_noise(obj, 'key', value, ...)
%
%
% where
%
% OBJ is a head.mri object
%
% 
% ## Accepted key/value pairs:
%
% 'Strength'    : A scalar that determines noise strength. Default: 1
%
%
% 
% See also: head.mri

% Description: Adds background noise
% Documentation: class_head_mri.txt


import misc.process_varargin;
import misc.euclidean_dist;

keySet = {'name','minstrength','maxstrength','strength', ...
    'minangle', 'maxangle', 'angle','activation'};

name        = 'noise';
minangle    = 0;
maxangle    = 180;
angle       = [];
minstrength = 0;
maxstrength = 1;
strength    = [];
activation  = 1;

eval(process_varargin(keySet, varargin));

if ~isempty(strength),
    minstrength = strength;
    maxstrength = strength;
end

if ~isempty(angle),
    minangle = angle;
    maxangle = angle;
end

obj = remove_source(obj, 'noise');

pickedPoints = [];
for i = 1:obj.NbSources
    pickedPoints = [pickedPoints;obj.Source(i).pnt(:)]; %#ok<AGROW>
end
cmass       = mean(obj.InnerSkull.pnt);
pickedPoints = setdiff(1:obj.NbSourceVoxels, pickedPoints);
volume = numel(pickedPoints);
sourcePoints= obj.SourceSpace.pnt(pickedPoints,:) - repmat(cmass, volume, 1);


% Randomize the strengths of the source dipoles
strength = repmat(minstrength, volume, 1)+...
    (maxstrength-minstrength)*rand(volume,1);

% Randomize the dipole angles
m = sourcePoints./repmat(euclidean_dist(sourcePoints, [0 0 0]), 1, 3);
[tmp1, tmp2, tmp3] = cart2sph(m(:,1), m(:,2), m(:,3));
mSph = [tmp1 tmp2 tmp3];
mSph2 = mSph;
angleShift = repmat(minangle, volume, 1)+(maxangle-minangle)*rand(volume, 1);
angleShift = 2*pi*(angleShift/360);
mSph2(:,2) = mSph2(:,2)+angleShift;
mSph2(:,1) = mSph2(:,1)+rand*2*pi;
[tmp1 tmp2 tmp3] = sph2cart(mSph2(:,1), mSph2(:,2), mSph2(:,3));
m2 = [tmp1 tmp2 tmp3];

momentum = repmat(strength,1,3).*m2;

% Create the source
if size(activation, 1) == 1,
    activation = repmat(activation, volume, 1);
end
source = struct('name', name, ...
    'strength', strength,...
    'orientation', m2, ...
    'angle', mod(360*(angleShift/(2*pi)), 360), ...
    'pnt', pickedPoints, ...
    'momentum', momentum, ...
    'activation', activation, ...
    'depth', obj.SourceSpace.depth(pickedPoints));
if isempty(obj.Source),
    obj.Source = source;
else
    obj.Source(end+1) = source;
end

% Rebuild the source leadfield
if ~isempty(obj.LeadField),
    obj = make_source_dipoles_leadfield(obj); 
end



end