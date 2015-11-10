function [sensor, M, distProj] = map2surf(sensor, scalp, varargin)
% MAP2SURF - Maps EEG sensors.onto the scalp surface
%
% [sensorNew, M] = map2surf(sensor, scalp)
%
% [sensorNew, M] = map2surf(sensor, scalp, 'key', value)
%
% Where
%
% SENSOR is a sensorCoord.eeg object
%
% SCALP is surface structure with a .pnt and .tri fields. Alternatively,
% SCALP can be a full path to a Freesurfer surface
% file in .tri format. If SCALP is a directory name, MAP2SURF will scan the
% directory and process all the .tri files that it contains
%
% SENSORNEW is an Nx3 matrix with the coordinates of the sensors.after
% being projected onto the scalp surface
%
% M is the NxN projection matrix from the old sensorCoord coordinates to the new
% ones
%
% ## Optional arguments can be passed as key/value pairs:
%
% to be done...
%
%
%
% See also: sensors.eeg

import misc.process_arguments;
import misc.nn_all;
import misc.nn_radius;
import misc.rdir;
import misc.eta;
import misc.plot_mesh;
import io.hpts.write;
import icp.ICP_finite;
import misc.euclidean_dist;

verboseLabel = '(sensors.eeg:map2surf) ';

% Some constants
EDGE_ALPHA = 0;%1;
FACE_ALPHA = 0;%1;
EDGE_COLOR = [0 0 0];
FACE_COLOR = [.3 .3 .3];

opt.reIcp       = false;
opt.icpPoints   = 30;
opt.hpts        = [];
opt.fig         = true;
opt.verbose     = true;
[~, opt] = process_arguments(opt, varargin);

sensorCoord = sensor.Cartesian;

triFileName = 'map2surf';
if ischar(scalp) && isempty(strfind(scalp, '*')),
    [scalp, ~, ~, facesScalp] = read_file(scalp);
elseif ischar(scalp),
    % scalp if a folder -> call recursively
    files = rdir(scalp);
    for i = 1:numel(files)
        [path, name] = fileparts(files(i).name);
        fname = [path filesep name '_' opt.fig '.opt.hpts'];
        [sensorNew, M, distProj] = ...
            map2surf(sensorCoord, files(i).name, varargin{:}, 'opt.hpts', fname);
        if opt.fig,
            fprintf('%s -> %s\n', name, fname);
        end
    end
    return;
else
    facesScalp = scalp.tri;
    scalp = scalp.pnt;
end

% Fix displacement between surface and sensors
nbSens = size(sensorCoord, 1);
headCenterSens = mean(sensorCoord);
headCenterSurf = mean(scalp);
displacement = headCenterSurf - headCenterSens;
sensorCoord = repmat(displacement, nbSens, 1) + sensorCoord;

% Fix the scale
radiusSens = mean(euclidean_dist(headCenterSurf, sensorCoord));
radiusSurf = mean(euclidean_dist(headCenterSurf, scalp));
scaleFactor = radiusSurf/radiusSens;
sensorCoord = scaleFactor*(sensorCoord-repmat(headCenterSurf, nbSens, 1))+...
    repmat(headCenterSurf, nbSens, 1);

% How close can two points be?
[~, radius] = nn_all(sensorCoord);
radius      = min(radius);

% First register the points
opt.Verbose = (opt.fig>1);
[sensorCoord, M] = ICP_finite(scalp, sensorCoord, opt);

% Project all points onto the surface starting from the closest pair
nSensors  = size(sensorCoord, 1);
nScalpVertices = size(scalp, 1);
sensorIdx   = 1:nSensors;
scalpIdx    = 1:nScalpVertices;
sensorNew   = nan(size(sensorCoord));
distProj    = nan(size(sensorCoord,1), 1);
if opt.verbose && nSensors > 0,
    fprintf([verboseLabel 'Projecting %d sensors.onto the skin surface...'] ...
        , nSensors);
end
tinit = tic;
runs  = nSensors;
count = 0;
while (nSensors > 0),
    [idxStatProj, dist] = nn_all(sensorCoord(sensorIdx,:), scalp(scalpIdx, :));
    % Project only the closest point
    [val, idx]                      = min(dist);
    idxStatProj                     = idxStatProj(idx);
    sensorNew(sensorIdx(idx), :)    = scalp(scalpIdx(idxStatProj), :);
    distProj(idx)                   = val;
    % Remove all points within a radius of the selected static point
    scalpIdx(nn_radius(scalp(scalpIdx(idxStatProj), :), scalp(scalpIdx, :), ...
        radius)) = [];
    % Remove the relevant dynamic point
    sensorIdx(idx) = [];
    nSensors  = nSensors - 1;
    count = count + 1;
    if opt.fig,
        misc.eta(tinit, runs, count);
    end
    if opt.reIcp && nSensors > opt.icpPoints,
        if opt.fig,
            fprintf([verboseLabel 'Running ICP on %d points...'], ...
                opt.icpPoints);
        end
        opt.Verbose      = opt.fig;
        sensorCoord(sensorIdx,:) = ICP_finite(scalp(scalpIdx,:), ...
            sensorCoord(sensorIdx,:), opt);
        if opt.fig,
            fprintf('\n');
        end
    end
end
if opt.verbose && (runs <= opt.icpPoints || ~opt.reIcp),
    fprintf('\n');
end

sensor.Cartesian = sensorNew;

if ~isempty(opt.hpts),
    [~, ~, ext] = fileparts(opt.hpts);
    if isempty(ext),
        opt.hpts = [opt.hpts '.opt.hpts'];
    end
    io.opt.hpts.write(opt.hpts, sensorNew, 'category', cat_dyn, 'id', id_dyn);
end

if opt.fig,
    tr = TriRep(facesScalp, scalp(:,1), scalp(:,2), scalp(:,3));
    h=trimesh(tr);
    set(h, ...
        'FaceColor', FACE_COLOR, ...
        'FaceAlpha', FACE_ALPHA, ...
        'EdgeColor', EDGE_COLOR', ...
        'EdgeAlpha', EDGE_ALPHA);
    
    hold on;
    
    scatter3(sensorNew(:,1), ...
        sensorNew(:,2), ...
        sensorNew(:,3), 'r', 'filled');
    
    axis equal;
    set(gca, 'visible', 'off');
    set(gcf, 'color', 'white');
    set(gcf, 'Name', triFileName);
end

end


function [sensorCoord, cat, id, faces] = read_file(sensorCoord)

faces = [];
% sensorCoord is a set of points in a .tri, .sfp or .opt.hpts file
[~, ~, ext] = fileparts(sensorCoord);
cat = [];
id = [];
switch lower(ext)
    case '.tri',
        [sensorCoord, faces] = io.tri.read(sensorCoord);
    case '.sfp',
        sensorCoord = io.sfp.read(sensorCoord)*10; % must be in mm
    case '.opt.hpts',
        [sensorCoord, cat, id] = io.opt.hpts.read(sensorCoord);
    case {'.gz', '.nii'},
        sensorCoord = io.mango.read(sensorCoord);
    otherwise,
        ME = MException(me, 'File %s is of unknown type', sensorCoord);
        throw(ME);
end

end