function obj = resample(obj, p, q)

if isempty(obj), return; end

duration    = get(obj, 'Duration');
sample      = get(obj, 'Sample');

newDuration = ceil(duration*p/q);
newSample = ceil(sample*p/q);

for i = 1:numel(obj)
    % Unchecked assignment for speed
    obj(i).Sample   = newSample(i);
    obj(i).Duration = newDuration(i);
end

end