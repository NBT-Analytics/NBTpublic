function obj = from_pset(pObj, varargin)
% FROM_PSET - Builds physioset from a pset object
%
% obj = physioset.from_pset(pObj);
% obj = physioset.from_pset(pObj, 'key', value, ...)
%
%
% Where
%
% POBJ is a pset object
%
% PHYSIOOBJ is a physioset object. If this argument is provided, then the
% generated physioset properties will be identical to those of PHYSIOOBJ
% but the actual data values will be those from POBJ.
%
% OBJ is an physioset object
%
% 
% ## Accepted key/value pairs:
%
% * All key/value pairs accepted by the contructor of the physioset.class
%
%
% ## Notes:
%
%   * The input argument POBJ will be invalidated after this operation due
%     the fact that the generated physioset will take ownership of the
%     memory-mapped file that was previously owned by POBJ.
%
%
% See also: physioset


import physioset.physioset;

obj = physioset(pObj, nb_dim(pObj), varargin{:});


end