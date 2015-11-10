function varargout = size(obj, dim)
% SIZE Size of a pset object
%
%   D = SIZE(OBJ) for a pset object OBJ containing M N-dimensional points,
%   returns the two-element row vector D = [N M]. If the pset object has
%   been transposed (i.e. its property Tranposed is set to true) then SIZE
%   returns the vector D = [M N].
%
%   [M,N] = SIZE(OBJ) for pset object OBJ, returns the number of dimensions
%   and points of OBJ as separate output variables.
%
%   [M1,M2,...,Mk] = SIZE(OBJ) returns M1=M, M2=N and Mk=1 for k>2.
%
% See also: pset.LENGTH, pset.NDIMS, pset.NUMEL

if nargout > 1 && nargin > 1,
    error('pset:pset:size:badopt','Unknown command option.');    
end

if nargin < 2   
    if nargout > 1,
        varargout = cell(nargout,1);
        for i = 1:nargout
            if i < 2
                if obj.Transposed,
                    varargout(i) = {nb_pnt(obj)};
                else
                    varargout(i) = {nb_dim(obj)};
                end
            elseif i < 3
                if obj.Transposed,
                    varargout(i) = {nb_dim(obj)};
                else
                    varargout(i) = {nb_pnt(obj)};
                end
            else
                varargout(i) = {1};
            end
        end
    else
        if obj.Transposed,
            varargout = {[nb_pnt(obj) nb_dim(obj)]};
        else
            varargout = {[nb_dim(obj) nb_pnt(obj)]};
        end
    end
else
    if dim > 2,
        varargout = {1};
    elseif dim > 1,
        if obj.Transposed,
            varargout = {nb_dim(obj)};
        else
            varargout = {nb_pnt(obj)};
        end
    elseif dim > 0,
        if obj.Transposed,
            varargout = {nb_pnt(obj)};
        else
            varargout = {nb_dim(obj)};
        end
    else
        error('pset:pset:size:dimensionMustBePositiveInteger', ...
            'Dimension argument must be a positive integer scalar within indexing range.');        
    end
    
end


