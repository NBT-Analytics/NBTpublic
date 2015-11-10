function x = filtfilt(obj, x, varargin)
% FILTFILT - Zero-phase forward and reverse low-pass digital filtering
%
% data = filtfilt(obj, data)
%
% where
%
% OBJ is a filter.lpfilt object
%
% DATA is the data to be filtered. DATA can be either a numeric matrix or
% an object of any class that behaves as such, e.g. a pset.pset or a
% pset.eegset object
%
%
% See also: filter.lpfilt, filter.lpfilt.filter


import misc.eta;

verboseLabel = get_verbose_label(obj);
verbose      = is_verbose(obj);

if verbose,
    if isa(x, 'pset.mmappset'),  
        name = get_name(x);
    else
        name = '';
    end
    fprintf([verboseLabel 'Filtering %s...'], name);
end
if verbose,
    tinit = tic;
    by100 = floor(size(x,1)/100);
    clear +misc/eta;
end
for i = 1:size(x, 1)
    if (isa(obj, 'physioset.physioset') && obj.BadChan(i)),
        continue;
    end
    
    xi = x(i, :);
    
    xi = filter(obj, xi);
    xi = filter(obj, fliplr(xi));
    x(i, :) = fliplr(xi);
   
    if verbose &&  ~mod(i, by100),
        eta(tinit, size(x,1), i, 'remaintime', false);
    end
end
if verbose,
    clear misc.eta;
    fprintf('\n\n');
end




end