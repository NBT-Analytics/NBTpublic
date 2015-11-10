function idx = pnt_selection(obj)


idx = obj.PntSelection;

if isempty(idx),
    idx = 1:obj.NbPoints;
end

end