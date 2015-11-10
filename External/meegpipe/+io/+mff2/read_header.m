function hdr = read_header(filename)

import mperl.split;
import mperl.file.spec.catfile;

% A minimalistic header
hdr.begin_time = perl('+io/+mff2/private/record_time.pl', filename);
hdr.signal = signal_info(filename);

epochsFilename = catfile(filename, 'epochs.xml');

if ~exist(epochsFilename, 'file'),
    warning('mff2:MissingEpochsInfo', ...
        'File epochs.xml is missing from %s', filename);   
    hdr.epochs = [];
    return;
end

epochInfo = perl('+io/+mff2/private/parse_epochs.pl', filename);
epochInfo = split(char(10), epochInfo);

for j = 1:numel(epochInfo)
    val = cellfun(@(x) str2double(x), split(';', epochInfo{j}));
    thisEpoch.begin_time = val(1);
    thisEpoch.end_time = val(2);
    thisEpoch.first_block = val(3);
    thisEpoch.last_block = val(4);
    hdr.epochs(j) = thisEpoch;    
end



end