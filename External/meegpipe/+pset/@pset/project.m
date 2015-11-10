function obj = project(obj, projM, bprojM)

if nargin < 2,
    return;
end

if nargin < 3 || isempty(bprojM),
    bprojM = pinv(projM);
end

if ~isempty(obj.DimMap),
    projM = projM*obj.DimMap;
end

if ~isempty(obj.DimInvMap),
    bprojM = obj.DimInvMap*bprojM;
end

if size(bprojM, 2) ~= size(projM, 1),
    error('Dimensions don''t match');
end

if size(projM,1) ~= obj.NbDims,
    error('Dimensions don''t match');
end

obj.DimMap      = projM;
obj.DimInvMap   = bprojM;


end