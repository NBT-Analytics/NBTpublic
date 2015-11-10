function obj = randn(nDims, nPoints, varargin)
% RANDN Builds a pset object filled with normally distributed random numbers
%
%   OBJ = randn(nDims, nPoints)
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
    ME = MException('randn:illegalArgument', ...
        'The nDims argument must be a natural scalar');
    throw(ME);
end

if numel(nPoints) > 1 || ~isnatural(nPoints),
    ME = MException('randn:illegalArgument', ...
        'The nPoints argument must be a natural scalar');
    throw(ME);
end

obj = pset.generate_data('randn', nDims, nPoints, varargin{:});