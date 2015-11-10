function pObj = import(obj, varargin)
% IMPORT - Imports a numeric data matrix
%
% pObj = import(obj, m1, m2, ...)
%
% Where
%
% M!, M2, ... are the numeric matrices to be imported
%
% POBJ is a physioset.object
%
% ## Notes:
%
% * The rows of the input data matrix will be assumed to be data channels
%   and the columns data samples. If the third dimension is not a singleton
%   dimension then it will be assumed to index data trials. Matrices of
%   more than 3 dimensions are not supported.
%
%
% See also: import, physioset.


import physioset.physioset;
import pset.pset;
import physioset.event.std.trial_begin;

% Deal with the multi-filename case
if nargin > 2
    pObj = cell(nargin-1, 1);
    for i = 1:numel(varargin)
        pObj{i} = import(obj, varargin{i});
    end
    return;
end

m = varargin{1};

if ndims(m) > 3,
    error('Matrices of more than three dimensions are not supported');
end

if size(m,3) > 1,
    % It is a trial-based dataset
    trialEvents = trial_begin(...
        1:size(m,2):(size(m,2)*size(m,3)), ...
        'Duration', size(m,2));
    trialEvents = set(trialEvents, 'Value', 1:size(m,3));
    m = reshape(m, size(m,1), size(m,2)*size(m,3));
   
else
    
    trialEvents = [];
    
end

% Cannot be temporary destructor will attempt to delete the memory-mapped
% file after m goes out of scope
psetArgs = construction_args_pset(obj);
m = pset.generate_data('matrix', m, psetArgs{:}, ...
    'ChunkSize', obj.ChunkSize, 'Temporary', false);

physiosetArgs = construction_args_physioset(obj);
pObj = physioset(m.DataFile, m.NbDims, ...
    psetArgs{:}, ...
    physiosetArgs{:});

if ~isempty(trialEvents),
    add_event(pObj, trialEvents);
end
