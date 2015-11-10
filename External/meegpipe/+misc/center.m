function y = center(a, varargin)
% CENTER Removes mean from a matrix
%
%   Y = CENTER(A) removes the mean from matrix A
%

if iscell(a),
    y = cell(size(a));
    for i = 1:numel(a)
        y{i} = misc.center(a{i});
    end
else
    try
        y = process(pset.node.center, a);
    catch ME
        if isnumeric(a) && ndims(a)>2,
            y = nan(size(a));
            for i = 1:size(a,3)
                y(:,:,i) = center(a(:,:,i));
            end
        elseif isnumeric(a) && ndims(a)==2,
            tmp = size(a,2);
            y = a - repmat(mean(a,2), 1, tmp);
        else
            rethrow(ME);
        end
    end
end
