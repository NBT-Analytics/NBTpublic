function y = subset(obj,varargin)
% SUBSET Selects a subset of dimensions/points from a pset object
%
%   OBJ2 = SUBSET(OBJ, I1, I2) creates a new pset object OBJ2 such that
%   OBJ2(:,:) = OBJ(I1, I2).
%
% See also: pset.pset

import pset.pset;
import misc.isnatural;

if nargin > 1 && isa(varargin{1}, 'pset.selector.selector'),
    
    select(varargin{1}, obj);
    i1 = obj.i1ection;
    i2 = obj.i2ection;
    restore_selection(obj);
    varargin = varargin(2:end);
    
elseif nargin > 2 && isnatural(varargin{2}),
    
    i1 = varargin{1};
    i2 = varargin{2};
    varargin = varargin(3:end);
    
elseif nargin > 1 && isnatural(varargin{1}),
    
    i1 = varargin{1};
    i2 = 1:nb_pnt(obj);
    varargin = varargin(2:end);
    
else
    
    i1 = 1:nb_dim(obj);
    i2 = 1:nb_pnt(obj);
    
end

if obj.Transposed,
    isTransposed   = true;
    obj.Transposed = false;
    tmp = i2;
    i2  = i1;
    i1  = tmp;
else
    isTransposed = false;
end


y = pset.nan(numel(i1), numel(i2), varargin{:});

idx = 1:max(obj.ChunkSize):length(i2);
if idx(end)<length(i2),
    idx = [idx length(i2)];
end    

s.type = '()';
for j = 1:(numel(idx)-1)
    thisIdx = idx(j):idx(j+1);
    thisIdx2 = i2(thisIdx);     
    s.subs = {i1, thisIdx2};    
    data = subsref(obj, s);
    s.subs = {1:numel(i1), thisIdx};
    y = subsasgn(y, s, data);
end

y.Transposed   = isTransposed;
obj.Transposed = isTransposed;








