function [x, obj] = filter(obj, x, varargin)

import misc.eta;

verbose         = is_verbose(obj) && size(x,1) > 10;
verboseLabel 	= get_verbose_label(obj);


if verbose,
    fprintf( [verboseLabel, 'Filtering %d signals...'], size(x,1));
end

if verbose,
    tinit = tic;
    clear +misc/eta;
end

delay = ceil((numel(obj.B) - 1)/2);

if 5*delay > size(x, 2),
    error(['Signal length (%d) must be at least 5 times as long as the ' ...
        'filter (%d)'], size(x,2), delay);
end

for i = 1:size(x,1),
   
    thisX = [fliplr(x(i, 1:(2*delay))) x(i,:)];
    
    
    y = filter(obj.B, obj.A, thisX);
    if numel(obj.A) > 1,
        x(i,:) = y(2*delay+1:end);
    else    
        x(i, 1:end-delay) = y((3*delay+1):end);
        x(i, end-delay+1:end) = fliplr(x(i, (end-2*delay+1):(end-delay)));
    end
    
    if verbose,
        eta(tinit, size(x,1), i, 'remaintime', false);
    end
    
end

if verbose, 
    fprintf('\n\n'); 
    clear +misc/eta;
end

end