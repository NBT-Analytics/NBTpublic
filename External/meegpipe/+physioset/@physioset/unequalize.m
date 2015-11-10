function obj = unequalize(obj, varargin)

import misc.process_arguments;
import misc.eta;

opt.verbose = true;

[~, opt] = process_arguments(opt, varargin);

if isempty(obj.Sensors) || isempty(obj.EqWeights),
    return;
end

[sensorGroups, idx] = sensor_groups(obj.Sensors);

sensorCount = 0;
tinit = tic;
for i = 1:numel(sensorGroups)
    for j = 1:numel(idx{i})
        obj.PointSet(idx{i}(j),:) = obj.PointSet(idx{i}(j),:)/...
            obj.EqWeightsOrig(idx{i}(j),idx{i}(j));
        sensorCount = sensorCount + 1;
        if opt.verbose,
            misc.eta(tinit, obj.NbDims, sensorCount);
        end
    end
    sensorGroups{i} = set_physdim_prefix(sensorGroups{i}, ...
        obj.PhysDimPrefixOrig(idx{i}));
end

obj.EqWeights = [];
obj.EqWeightsOrig = [];
obj.PhysDimPrefixOrig = [];


end