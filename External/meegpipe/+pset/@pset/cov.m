function y = cov(a, b, flag)
% COV Covariance matrix 
%
%   C = cov(OBJ) where OBJ is a pset object with dimensionality N and C is
%   a CxC covariance matrix.
%
% See also: pset.pset

transFlag = false;
if a.Transposed,
    transFlag = true;
    a.Transposed = false;
end

if nargin < 2 || isempty(b) || ~all(size(a) == size(b)),     
    % This is by far the most common case, so do some effort and avoid 
    % calling sub-functions such as center() or copy()
    
    % Calculate mean vector
    mv = zeros(size(a,1), 1);
    for i = 1:a.NbChunks
        [~, dataa] = get_chunk(a, i);
        mv = mv + sum(dataa, 2);
    end
    mv = mv./size(a,2);
    
    % Calculate the covariance matrix
    y = zeros(size(a,1));
    for i = 1:a.NbChunks
        [~, dataa] = get_chunk(a, i);
        this = dataa-repmat(mv, 1, size(dataa,2));
        y = y + this*this';
    end
 
elseif all(size(a) == size(b))
    
    % Remove the mean (this will modify the input data!!)
    center(a);
    center(b);
    y = a*b';
    
end

if nargin > 1 && numel(b) == 1,
    flag = b;
elseif nargin < 3
    flag = 0;
end

if flag == 1,
    y = (1/nb_pnt(a))*y;
else
    y = (1/(nb_pnt(a)-1))*y;
end

if transFlag,
    a.Transposed = true;
end
