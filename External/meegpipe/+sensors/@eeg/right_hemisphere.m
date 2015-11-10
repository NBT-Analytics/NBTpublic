function [sens, isRight] = right_hemisphere(obj)

isRight = obj.Cartesian(:,1) > 0;
sens = subset(obj, isRight);

end