function ev = get_pnt_selection_events(obj, ev)


import physioset.event.std.epoch_begin;

if nargin < 2 || isempty(ev), 
    ev = epoch_begin(NaN, 'Type', '__DataSelection'); 
end

idx = obj.PntSelection;

if isempty(idx), 
    ev = [];
    return; 
end

idxDiff = diff(idx);

bndry  = find(idxDiff > 1);

if ~isempty(bndry),
    bndry = bndry + 1;
end

if idx(1) > 1 || idx(end) < obj.PointSet.NbPoints,
    bndry = [1 bndry];
end

if isempty(bndry), return; end

dur = diff([bndry numel(idx)+1]);

% Add discontinuity events at each boundary between selected/non-selected
ev = repmat(ev, 1, numel(bndry));
ev = set_sample(ev, bndry);

for i = 1:numel(ev),
    ev(i) = set(ev(i), 'Duration', dur(i));
end



end