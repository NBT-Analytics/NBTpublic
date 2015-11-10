function [y, I] = proj(obj, data, fullMatrix)

if nargin < 3 || isempty(fullMatrix), fullMatrix = false; end

W = projmat(obj, fullMatrix);

if isa(data, 'physioset.physioset'),
    backup_sensors(data, obj);
end

y = W*data;

if fullMatrix,
    I = 1:size(W,1);
else
    I = component_selection(obj);
end

end