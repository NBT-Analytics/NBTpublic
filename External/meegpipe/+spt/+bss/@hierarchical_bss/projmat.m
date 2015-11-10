function W = projmat(obj, varargin)

W = projmat_win(obj, varargin{:});

W = median(W, 3);

end