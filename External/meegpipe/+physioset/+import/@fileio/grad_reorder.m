function grad = grad_reorder(grad, megIdx)

if isfield(grad, 'chanori'),
    field = {'chanori', 'chanpos', 'chantype', 'chanunit', 'label', 'tra'}; 
else
    % Old Fieldtrip version
    field = {'pnt', 'ori', 'tra', 'label'};
end

for fieldItr = field
    grad.(fieldItr{1}) = grad.(fieldItr{1})(megIdx, :);
end

end