function y = end(obj, dim, ~)
% END Last index in an indexing expression 

if dim > 2,
    y = 1;
elseif dim > 1,
    if ~obj.Transposed,
        y = obj.NbPoints;
    else
        y = obj.NbDims;
    end
else
    if ~obj.Transposed,
        y = obj.NbDims;
    else
        y = obj.NbPoints;
    end
end


end