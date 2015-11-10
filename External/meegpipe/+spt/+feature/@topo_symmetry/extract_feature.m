function [featVal, featName] = extract_feature(obj, sptObj, ~, data, varargin)

import misc.euclidean_dist;
featName = [];

sens = sensors(data);
xyz  = cartesian_coords(sens);

minX = min(xyz(:,1));
maxX = max(xyz(:,1));
minY = min(xyz(:,2));
maxY = max(xyz(:,2));

M = bprojmat(sptObj).^2;

isLeft  = xyz(:,1) < obj.R0*minX & xyz(:,1) > obj.R1*minX;
isRight = xyz(:,1) < obj.R1*maxX & xyz(:,1) > obj.R0*maxX;

% Difference with the RH
leftIdx = find(isLeft);
rightIdx = find(isRight);
diffVal = zeros(1, size(M, 2));

M = misc.unit_norm(M);

for i = 1:numel(leftIdx)
   dist = euclidean_dist([-xyz(leftIdx(i),1) xyz(leftIdx(i),2:3)], ...
       xyz(isRight, :));
   [~, closestIdx] = min(dist);
   diffVal = diffVal + ...
       abs(M(rightIdx(closestIdx), :)-M(leftIdx(i), :));
end

isFront = xyz(:,2) >= obj.R0*maxY & xyz(:,2) <= obj.R1*maxY;
isBack  = xyz(:,2) <= obj.R0*minY & xyz(:,2) >= obj.R1*minY;
% Difference with the RH
frontIdx = find(isFront);
backIdx = find(isBack);
diffVal2 = zeros(1, size(M, 2));

M = misc.unit_norm(M);

for i = 1:numel(frontIdx)
   dist = euclidean_dist([-xyz(frontIdx(i),1) xyz(frontIdx(i),2:3)], ...
       xyz(isRight, :));
   [~, closestIdx] = min(dist);
   diffVal2 = diffVal2 + ...
       abs(M(backIdx(closestIdx), :)-M(frontIdx(i), :));
end

featVal = diffVal2./diffVal;


end