function [bndry, index] = chop(obj, data, varargin)


index = 1:obj.WindowLength:size(data,2);

bndry = false(1, size(data,2));

bndry(index) = true;


end
