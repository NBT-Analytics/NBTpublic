function cellArray = argarray(obj, section, params)
import mperl.perl;
import mperl.config.inifiles.*;

values = val(obj, section, params);

cellArray = cell(1, numel(params)*2);
cellArray(1:2:end) = params;
cellArray(2:2:end) = values;

end