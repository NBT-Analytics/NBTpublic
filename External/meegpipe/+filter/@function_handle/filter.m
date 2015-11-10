function x = filter(obj, x, varargin)

import misc.eta;
import misc.any2str;
import misc.sizeof;

if isempty(obj.Operator),
    return;
end

verbose         = is_verbose(obj) && size(x,1) > 10;
verboseLabel 	= get_verbose_label(obj);

if verbose,
    fprintf( [verboseLabel, 'Filtering %d signals using %s...'], ...
        size(x,1), any2str(obj.Operator));
end

if verbose,
    tinit = tic;
    clear +misc/eta;
end

if strcmpi(obj.Dim, 'cols'),
    
    % Accelerate things by operating in chunks
    maxChunk = pset.globals.get.ChunkSize;
    maxCols  = maxChunk/(size(x,1)*sizeof(class(x(1))));
    nbChunks = ceil(size(x,2)/maxCols);
    idx      = ceil(linspace(0, size(x,2), nbChunks+1));
    
    for j = 1:nbChunks

        thisIdx = (idx(j)+1):idx(j+1);
        x(:, thisIdx) = obj.Operator(x(:, thisIdx));
        
        if verbose ,
            eta(tinit, nbChunks, j, 'remaintime', false);
        end
        
    end
else
    for i = 1:size(x,1),
        
        x(i,:) = obj.Operator(x(i, :));
        
        if verbose,
            eta(tinit, size(x,1), i, 'remaintime', false);
        end
        
    end
    
end

if verbose, 
    fprintf('\n\n'); 
    clear +misc/eta;
end

end