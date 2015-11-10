function [sens, isLeft] = left_hemisphere(obj)


isLeft = obj.Cartesian(:,1) < 0;
sens = subset(obj, isLeft);


end