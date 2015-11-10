function A = bprojmat(obj, varargin)

A = bprojmat_win(obj, varargin{:});

A = median(A, 3);

end