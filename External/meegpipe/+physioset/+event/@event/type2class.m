function ev = type2class(ev, mapHash)
% TYPE2CLASS - Map events of certain types to certain event classes
%
% See also: event

for i = 1:numel(ev)
   
    newClass = mapHash(ev(i).Type);
    if ~isempty(newClass),
        ev(i) = eval(['physioset.event.std.' newClass '(ev(i))']);
    end
    
end

end