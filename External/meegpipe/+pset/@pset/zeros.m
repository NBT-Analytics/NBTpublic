function obj = zeros(nDims, nPoints, varargin)
% ZEROS Builds a pset object filled with zeroes
%
%   OBJ = zeros(nDims, nPoints) creates a temporary pset object OBJ that
%   contains a pointset of dimensionality nDims and cardinality nPoints. 
%
%
% See also: pset.pset

import pset.pset;
import misc.isnatural;

if nargin < 1, nDims = []; end
if nargin < 2, nPoints = []; end
if nargin < 3, varargin = {}; end

if nargin == 1,
    if numel(nDims) == 1,
        nPoints = nDims;
    else
        nPoints = nDims(2);
        nDims = nDims(1);
    end
end

if numel(nDims) > 1 || ~isnatural(nDims),
    ME = MException('zeros:illegalArgument', ...
        'The nDims argument must be a natural scalar');
    throw(ME);
end

if numel(nPoints) > 1 || ~isnatural(nPoints),
    ME = MException('zeros:illegalArgument', ...
        'The nPoints argument must be a natural scalar');
    throw(ME);
end

obj = pset.generate_data('zeros', nDims, nPoints, varargin{:});