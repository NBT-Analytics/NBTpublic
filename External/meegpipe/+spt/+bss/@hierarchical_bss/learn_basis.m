function obj = learn_basis(obj, data, varargin)

import misc.eta;
import spt.centroid_spt;


obj = apply_seed(obj);

verbLevel    = get_verbose_level(obj);
verboseLabel = get_verbose_label(obj);

% Step 1: Centroid BSS on the whole dataset
if verbLevel > 0,
    fprintf([verboseLabel ...
        'Learning %s basis for parent from %d surrogates ...'], ...
        class(obj.BSS), obj.ParentSurrogates);
end
tinit = tic;
bssObj     = cell(1, obj.ParentSurrogates);


surrogator = obj.Surrogator;

for surrIter = 1:obj.ParentSurrogates  
    
    surrogator = set_seed(surrogator, get_seed(obj) + surrIter*100);
    dataSurr = surrogate(surrogator, data(:,:));    
  
    bssObj{surrIter} = learn_basis(obj.BSS, dataSurr, varargin{:});
   
    if verbLevel > 0
        misc.eta(tinit, obj.ParentSurrogates, surrIter);
    end
    
end
if verbLevel > 0,
    fprintf('\n\n');
end

[bssCentroid, idx, distVal] = centroid_spt(bssObj, obj.DistanceMeasure);
if verbLevel > 0,
    fprintf([verboseLabel 'Average distance to centroid BSS: %.2f\n\n'], ...
        mean(distVal(setdiff(1:numel(distVal), idx))));
end

% Step 2: Apply centroid BSS to whole dataset
data = copy(data);

proj(bssCentroid, data, true);

% Step 3: Split the dataset into two sets
[bssArray, winBoundary] = learn_lr_basis(obj, data, bssCentroid, ...
    [1, size(data, 2)]);

% Step 4: Cascade the parent BSS with the left/right BSS
if numel(bssArray) > 1,
    for i = 1:numel(bssArray)
        bssArray{i} = cascade(bssCentroid, bssArray{i});
    end
end

% Step 5: Realign all BSSs
bssCentroid = centroid_spt(bssArray, obj.DistanceMeasure);
for i = 1:numel(bssArray)
   bssArray{i} = match_sources(bssArray{i}, bprojmat(bssCentroid)); 
end

obj.BSSwin = bssArray;
obj.WinBoundary = winBoundary;

obj.ComponentSelection = 1:nb_component(bssArray{1});
obj.DimSelection       = 1:nb_dim(bssArray{1});

end



