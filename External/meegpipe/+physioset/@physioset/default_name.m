function name = default_name(obj)
% DEFAULT_NAME - Default physioset object name

import datahash.DataHash;

dataFile = get_datafile(obj);

if isempty(dataFile),
    name = 'physioset';
    return;
end

[~, fileName] = fileparts(dataFile);

if numel(fileName) > 50,
    
    name = DataHash(fileName);
    
else
    name = fileName;
    
end

end