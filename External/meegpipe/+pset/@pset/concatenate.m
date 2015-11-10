function obj = concatenate(varargin)

import pset.pset;
import misc.eta;

if nargin < 1,
    obj = [];
    return;
end

count = 1;
while count <= numel(varargin) && isa(varargin{count}, 'pset.pset'),
    count = count +1 ;
end
otherArgs = varargin(count:end);
varargin = varargin(1:count-1);

verbose             = is_verbose(varargin{1});
verboseLabel        = get_verbose_label(varargin{1});

% Check that no pset has selections
if any(cellfun(@(x) has_selection(x), varargin))
    error('Cannot merge pset objects that have selections');
end

if numel(varargin) < 2,
    obj = copy(varargin{1}, otherArgs{:});
    return;
end

nbDims       = varargin{1}.NbDims;
nbPoints     = 0;
for i = 1:numel(varargin)
   if size(varargin{i}, 1) ~= nbDims,
       error('pset:concatenate:WrongDimensions', ...
           'Cannot concatenate psets of different dimensionalities');
   end
   nbPoints = nbPoints + size(varargin{i}, 2); 
end


if verbose,
    fprintf(...
        [verboseLabel 'Merging data values from %d psets ...'], ...
        numel(varargin));
end
tinit = tic;
obj = pset.nan(nbDims, nbPoints, otherArgs{:});
if verbose, eta(tinit, numel(varargin)*2, numel(varargin)); end

count = 0;
s.type = '()';
for i = 1:numel(varargin)
    for j = 1:varargin{i}.NbChunks
        [index, data] = get_chunk(varargin{i}, j);
        s.subs = {1:nbDims, index+count};         
        obj = subsasgn(obj, s, data);        
    end    
    count = count + varargin{i}.NbPoints;
    if verbose, eta(tinit, numel(varargin)*2, numel(varargin)+i); end
end
if verbose,
    fprintf('\n\n');
    clear +misc/eta;
end

obj.Writable    = varargin{1}.Writable;
obj.Temporary   = varargin{1}.Temporary;


end