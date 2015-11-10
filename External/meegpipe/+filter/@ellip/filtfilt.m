function x = filtfilt(obj, x, varargin)
% FILTER - One-dimensional high-pass digital filtering
%
%   y = filtfilt(obj, x)
%
%
% where
%
% OBJ is a filter.hpfilt object
%
% X is the KxM data matrix to be filtered. X can be a numeric data matrix
% or an object of any class with suitably overloaded subsref and subsasgn
% operators (e.g. a pset or a physioset object).
%
% Y is the filtered data matrix (or pset/physioset object). Note that if X
% is a pset or physioset object, then Y and X are just aliases to the same
% underlying data.
%
%
% See also: filter.hpfilt_ellip


import misc.eta;

verbose         = is_verbose(obj);
verboseLabel    = get_verbose_label(obj);

if verbose,
    if isa(x, 'physioset.physioset'),
        fprintf([verboseLabel 'HP-filtering %s...'], get_name(x));
    else
        fprintf([verboseLabel 'HP-filtering...']);
    end
end

if verbose,
    tinit = tic;
    by25 = floor(size(x,1)/25);
    clear +misc/eta;
end

for i = 1:size(x, 1)
    if isa(obj, 'physioset.physioset') && obj.BadChan(i),
        continue;
    end
    x(i, :) = filtfilt(obj.H.sosMatrix, obj.H.ScaleValues, x(i,:));
    if verbose && ~mod(i, by25)
        eta(tinit, size(x,1), i, 'remaintime', false);
    end
end
if verbose,
    fprintf('\n\n');
end
