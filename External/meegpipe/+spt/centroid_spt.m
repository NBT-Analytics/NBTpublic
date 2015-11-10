function [bssCentroid, centroidIdx, distVal] = centroid_spt(bssArray, distMeas, aggr)

if nargin < 3 || isempty(aggr), aggr = @(dist) mean(dist); end

dMat = nan(numel(bssArray));

for i = 1:numel(bssArray)
    for j = 1:numel(bssArray),
        if i == j, continue; end
        dMat(i,j) = distMeas(bssArray{i}, bssArray{j});
    end
end

aggrDist = nan(size(dMat,1), 1);
for i = 1:size(dMat,1)
   aggrDist(i) = aggr(dMat(i,:)); 
end

[~, centroidIdx] = min(aggrDist);

bssCentroid = bssArray{centroidIdx};

distVal = dMat(centroidIdx,:);
distVal(centroidIdx) = 0;


end