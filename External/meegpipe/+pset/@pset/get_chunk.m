function [pIndex, y] = get_chunk(obj, chunkIdx)
% get_chunk - Gets a data chunk from a pset object
%
%   [pIndex, DATA] = get_chunk(OBJ, chunkIdx) returns a data chunk from
%   a pset object OBJ. The second input argument is the index of the chunk.
%   The second output argument is a numeric matrix with the point values 
%   corresponding to the given chunk. The first output (pIndex) is an
%   array with the indices that correspond to the points in the chunk. The
%   number of chunks that are needed to load a whole pset object is
%   stored in property NbChunks.
%
%   Note that the dimensions of DATA depend on whether the pset has or has
%   not been tranposed.
%
%   See also: pset.pset.SUBSREF

nbChunks = obj.NbChunks;
if chunkIdx > nbChunks || chunkIdx < 0,
    error('pset:pset:get_chunk', ...
        'Chunk index must be a natural number less than %d', nbChunks);
elseif chunkIdx > (nbChunks-1),
    pIndex = obj.ChunkIndices(chunkIdx):obj.NbPoints;    
else
    pIndex = obj.ChunkIndices(chunkIdx):obj.ChunkIndices(chunkIdx+1)-1;    
end

if ~isempty(obj.PntSelection),
    [~, ia] = intersect(obj.PntSelection, pIndex);
    pIndex = ia;    
end

if obj.Transposed,
    s.type = '()';
    s.subs = {pIndex, 1:nb_dim(obj)};
    y = subsref(obj, s);
else
    s.type = '()';
    s.subs = {1:nb_dim(obj), pIndex};
    y = subsref(obj, s);
end