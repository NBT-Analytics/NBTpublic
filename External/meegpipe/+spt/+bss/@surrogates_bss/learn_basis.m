function obj = learn_basis(obj, data, varargin)

import misc.eta;
import spt.centroid_spt;
import mperl.join;


obj = apply_seed(obj);

verbLevel    = get_verbose_level(obj);
verboseLabel = get_verbose_label(obj);

if verbLevel > 0,
    bssClasses = cellfun(@(x) class(x), obj.BSS, 'UniformOutput', false);
    fprintf([verboseLabel ...
        'Learning %s basis from %d surrogates ...'], ...
        join(', ', bssClasses), obj.NbSurrogates);
end

tinit = tic;
bssObj     = cell(numel(obj.BSS), obj.NbSurrogates);
surrogator = obj.Surrogator;
bss        = obj.BSS;

count = 0;
for bssIter = 1:numel(bss)
    for surrIter = 1:obj.NbSurrogates
        surrogator = set_seed(surrogator, get_seed(obj) + surrIter*100);
        dataSurr = surrogate(surrogator, data);
        bssObj{bssIter, surrIter} = learn_basis(bss{bssIter}, dataSurr, varargin{:});
        if isa(data, 'physioset.physioset'),
            restore_selection(data);
        end
        count = count + 1;
    end
    
    if verbLevel > 0
        misc.eta(tinit, obj.NbSurrogates*numel(bss), count);
    end
end
if verbLevel > 0,
    fprintf('\n\n');
end

if verbLevel > 0,
    fprintf([verboseLabel 'Finding centroid BSS ...']);
end
[bssCentroid, idx, distVal] = centroid_spt(bssObj, obj.DistMeas, ...
    obj.DistAggregator);
if verbLevel > 0, fprintf('[done]\n\n'); end

% For convenience only, we align all BSS surrogates with the centroid as
% this is likely to be something the user may want to make
if verbLevel > 0,
    fprintf([verboseLabel 'Aligning surrogate BSSs with centroid BSS ...']);
end
tinit = tic;
for i = 1:numel(bssObj)
    if i == idx; continue; end
    bssObj{i} = match_sources(bssObj{i}, bprojmat(bssCentroid));
    if verbLevel > 0,
        misc.eta(tinit, numel(bssObj), i);
    end
end
if verbLevel > 0, fprintf('\n\n'); end

obj.BSSSurr = bssObj;
obj.CentroidDistance = distVal;
obj.CentroidIdx = idx;

if verbLevel > 0,
    nonCentroidIdx = setdiff(1:numel(distVal), idx);
    distVal = distVal(nonCentroidIdx);
    fprintf([verboseLabel 'Distance to centroid BSS: mean=%.2f; max=%.2f\n\n'], ...
        mean(distVal), max(distVal));
end


end