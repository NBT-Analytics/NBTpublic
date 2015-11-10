function obj = make_leadfield(obj, verbose)
import fieldtrip.ft_prepare_leadfield;
import misc.eta; 

if nargin < 2, verbose = true; end

MissingBEM = MException('head:mri:make_source_grid_leadfield', ...
    'You need to run make_bem() first!');

if isempty(obj.FieldTripVolume),
    throw(MissingBEM);
end


% Generate the leadfield matrix
cfg.grid.pos = obj.SourceSpace.pnt;
cfg.grid.inside = 1:size(obj.SourceSpace.pnt, 1);
cfg.grid.outside = [];
cfg.vol = obj.FieldTripVolume;
cfg.elec = fieldtrip(obj.Sensors);
try
    grid = ft_prepare_leadfield(cfg);
catch  %#ok<CTCH>
    % Older versions of fieldtrip have a bug that requires leadfield to be
    % called twice
    grid = ft_prepare_leadfield(cfg);
end

obj.LeadField = nan(obj.NbSensors, 3, obj.NbSourceVoxels);
for i = 1:obj.NbSourceVoxels,
    obj.LeadField(:,:,i) = grid.leadfield{i};
end

% Compute the normals at each vertex
obj.InnerSkullNormals = zeros(size(obj.InnerSkull.pnt,1), 3);
TR = TriRep(obj.InnerSkull.tri, obj.InnerSkull.pnt);
fN = faceNormals(TR);
if verbose,
    fprintf('\n\nComputing vertex normals ... ');
    tinit = tic;
end
iterBy100 = max(1, floor(size(obj.InnerSkull.pnt, 1)/100));
for i = 1:size(obj.InnerSkull.pnt, 1),
    [row, ~] = find(obj.InnerSkull.tri == i);
    obj.InnerSkullNormals(i,:) = mean(fN(row,:));
    if ~mod(i, iterBy100) && verbose,
        misc.eta(tinit, size(obj.InnerSkull.pnt, 1), i);
    end
end
if verbose,fprintf('\n\n');end

A = zeros(obj.NbSensors, obj.NbSourceVoxels);

for i = 1:obj.NbSourceVoxels
    A(:,i) = squeeze(obj.LeadField(:,:,i))*obj.InnerSkullNormals(i,:)';
end

obj.SourceDipolesLeadField = A;


end