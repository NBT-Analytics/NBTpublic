function nbEvent = nb_event(obj)
% NB_EVENT - Number of events contained in a physioset object
%
% nbEvent = nb_event(obj)
%
% See also: nb_pnt, nb_dim, physioset, pset.event

pntSel = pnt_selection(obj);
if ~isempty(pntSel),
    
    evSel = physioset.event.sample_selector(pntSel);
    nbEvent = numel(select(evSel, obj.Event));
    
else
    nbEvent = numel(obj.Event);
end


end