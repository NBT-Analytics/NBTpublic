function varargout = cascade(varargin)

obj = varargin{1};

W = projmat(obj);
A = bprojmat(obj);
for i = 2:nargin
    W = projmat(varargin{i})*W;
    A = A*bprojmat(varargin{i});    
end

varargout = varargin;

for i = 1:nargout
    
    varargout{i}.W = W;
    varargout{i}.A = A;
    varargout{i}.ComponentSelection = 1:size(W,1);
    varargout{i}.DimSelection = 1:size(A,1);
    varargout{i}.ComponentSelectionH = {};
    varargout{i}.DimSelectionH = {};
    
end


end