function y = center(a)
% CENTER Removes the mean from a pset object
%
%   Y = CENTER(A) generates a zero-mean pset object Y which is otherwise
%   identical to A.
%
% See also: pset.pset

import misc.eta;

verbose         = is_verbose(a);
verboseLabel    = get_verbose_label(a);

transposed_flag = false;
if a.Transposed,
    transposed_flag = true;
    a.Transposed = false;
end
if verbose,
    [~, fname] = fileparts(a.DataFile);
    fprintf([verboseLabel 'Centering ''%s''...'], fname);
    pause(0.01);
end

nbChunks = a.NbChunks;

chunkSize = max(1, floor(size(a,2)/nbChunks));

init = 1:chunkSize:size(a,2);

dataMean = repmat(mean(a,2), 1, chunkSize);

y = a;
tinit = tic;
for i = 1:numel(init)-1
    
    s.type = '()';
    colIdx = init(i):init(i+1)-1;
    s.subs = {1:nb_dim(a), colIdx};
    chunkData = subsref(a, s);
    y = subsasgn(y, s, chunkData-dataMean);
    
    if verbose,
        eta(tinit, numel(init)-1, i);
    end
    
end

% Last chunk
colIdx = init(end):size(a,2);
s.type = '()';
s.subs = {1:nb_dim(a), colIdx};
chunkData = subsref(a, s);
y = subsasgn(y, s, chunkData-dataMean(:,1:numel(colIdx)));


if transposed_flag,
    y.Transposed = true;
    a.Transposed = true;
end

if verbose, 
    fprintf('\n\n');
end
