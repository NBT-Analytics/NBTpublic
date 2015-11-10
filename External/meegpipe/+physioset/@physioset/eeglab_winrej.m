function winrej = eeglab_winrej(obj)
% EEGLAB_WINREJ - Produces EEGLAB epoch rejection matrix
%
%
% winrej = eeglab_winrej(obj)
%
%
% Where
%
% OBJ is a physioset.object
%
% WINREJ is an epoch rejection definition matrix
%
%
% See also: pset.eegset

first = find(diff(is_bad_sample(obj))>0);
last  = find(diff(is_bad_sample(obj))<0);

if ~isempty(first),
    first = first + 1;
end

if isempty(first) && isempty(last),
    if all(is_bad_sample(obj)),
        % Every sample is bad
        first = 1;
        last = nb_pnt(obj);
    else
        % Everything is good
    end
elseif numel(first) == numel(last),
    if last(1) < first(1),
        first = [1 first];
        last  = [last nb_pnt(obj)];
    end
elseif numel(first)<numel(last)
    first = [1 first];
else
    last = [last nb_pnt(obj)];
end

if ~isempty(first),
    winrej = [first(:) last(:) repmat([0.7 0.5 0.9], numel(first),1) ...
        true(numel(first), nb_dim(obj))];
else
    winrej = [];
end

end