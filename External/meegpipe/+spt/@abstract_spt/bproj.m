function [y, I] = bproj(obj, data, fullMatrix)

if nargin < 3 || isempty(fullMatrix), fullMatrix = false; end

A = bprojmat(obj, fullMatrix);

if fullMatrix,
    I = size(A,1);
else
    I = dim_selection(obj);
end
Ic = component_selection(obj);

if ~fullMatrix,
    if isa(data, 'pset.mmappset'),
        select(data, Ic);
    else
        data = data(Ic,:);
    end
end
y = A*data;
if ~fullMatrix,
    if isa(data, 'pset.mmappset'),
        restore_selection(data);
    end
end

if isa(y, 'physioset.physioset'),
    restore_sensors(data, obj);
end


end