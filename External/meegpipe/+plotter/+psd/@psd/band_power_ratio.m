function ratios = band_power_ratio(obj)

if isempty(obj.Data),
    ratios = [];
    return;
end

import plotter.psd.power_ratios;

bois = get_config(obj, 'BOI');

ratios = power_ratios(obj.Data(1), bois, true);

end