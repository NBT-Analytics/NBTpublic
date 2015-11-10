function [sens, isMidline] = midline(obj)

isMidline = obj.Cartesian(:,1) == 0;
sens = subset(obj, isMidline);

end