function grad = grad_change_unit(grad, newUnit)
import mjava.hash;

if ~isfield(grad, 'unit') || strcmpi(grad.unit, newUnit),
    return;
end

units = hash;
units{'cm', 'mm', 'm'} = {1, 0.1, 100};

factor = units(grad.unit);
if isempty(factor),
    error('physioset:import:fileio:grad_change_unit:InvalidUnit', ...
        'Unknown MEG sensor positions units: %s', grad.unit);
end
grad.chanpos = grad.chanpos*factor;
grad.coilpos = grad.coilpos*factor;

end