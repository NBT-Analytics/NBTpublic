function y = euclidean_dist(a,b)
% EUCLIDEAN_DIST - Euclidean distance between two points
%
%   EUCLIDEANDIST(A,B) where A and B give the three cartesian coordinates
%   of two points in the space returns the Euclidean distance between those
%   two points.
%
%   EUCLIDEANDIST(A,B) where A and B are two matrices of dimensions Kx3
%   returns a vector of dimensions Kx1 with the Euclidean distance between
%   the rows of A and the rows of B. 
%
%   EUCLIDEANDIST(A,B) where A (or B) is a vector and the other input
%   is a Kx3 matrix returns the Euclidean distance between the single point
%   in the space given by A (or B) and the multiple points given by the
%   other input parameter.

if nargin < 2, 
    ME = MException('euclideanDistance:needMoreInputs','Some input parameters are missing');
    throw(ME);
end

if size(a,1) ~= size(b,1) && size(a,1)>1 && size(b,1) > 1,
    ME = MException('euclideanDist:invalidDim','Invalid dimensions in input parameter.');
    throw(ME);
end

if size(a,1) > size(b,1),
    tmp = a;
    a = b;
    b = tmp;
    clear tmp;
elseif size(a,1)>1 && size(a,1) == size(b,1),
    y = nan(size(a,1),1);
    for i = 1:size(a,1)
       y(i) = misc.euclidean_dist(a(i,:), b(i,:));       
    end
    return;
end
   
a = repmat(a,size(b,1),1);

y = sqrt(sum((a-b).^2,2));