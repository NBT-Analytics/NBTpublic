function cellcheck(checkfun, ME, varargin)

if nargin < 3,
    error('At least 3 input arguments are expected');
end

for i = 1:numel(varargin{1}),
    args  = cell(1, nargin-2);
    for j = 1:nargin-2,
       args{j} = varargin{j}{i}; 
    end
    if ~checkfun(args{:}),
        throw(ME);
    end
end

end