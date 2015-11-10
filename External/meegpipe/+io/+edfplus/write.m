function write(fname, data, sr, varargin)

import edfplus.globals;
import misc.process_arguments;

keySet = {...   
    'header', ...
    'verbose', ...
    'verboselabel' ...
    };

verbose = true;
verboseLabel = '(edfplus.write)';
header = edfplus.header.egi(size(data,1));

eval(process_arguments(keySet, varargin));

% Compute number of records, record duration and samples per record
[nbRec, recDur, spr] = data2records(data, sr);


fid = fopen(filename, 'w', 'ieee-le');
try
    fwrite(fid, as_string(header, nbRec, recDur, spr), 'char');    
    
catch ME
    fclose(fid);
    rethrow(ME);
    
    
end
    
    
end


end