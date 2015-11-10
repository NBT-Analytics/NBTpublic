function value = nb_pnt(obj)


if isempty(obj.PntSelection),
    value = obj.NbPoints;
else
    value = numel(obj.PntSelection);
end


end