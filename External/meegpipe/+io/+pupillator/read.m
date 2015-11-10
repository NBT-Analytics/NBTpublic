function [pup, prot, dataHdr, protHdr] = read(filename)

import safefid.safefid;
import mperl.split;
import misc.strtrim;

% Old pupillator has only 5 columns in the protocol description, but
% pupillator 2.0 has 6 columns! 
prot = nan(100, 6);

fid = safefid(filename, 'r');

ln = fgetl(fid);

lnCount = 1;

[ln, prevLn, count] = skip_until_numeric(fid, ln);

lnCount = lnCount + count;

protHdr = cellfun(@(x) strtrim(x), split(',', prevLn), ...
    'UniformOutput', false);

[prot, ln, count] = read_data(fid, ln, prot, []);

lnCount = lnCount + count;

[~, prevLn, count] = skip_until_numeric(fid, ln);

lnCount = lnCount + count;

dataHdr = cellfun(@(x) strtrim(x), split(',', prevLn), ...
    'UniformOutput', false);

%data = read_data(fid, ln, data, maxCount);

clear fid;
pup = dlmread(filename, ',', lnCount-1, 0);

end



function [ln, prevLn, count] = skip_until_numeric(fid, ln)

% Read until the start of the protocol description
prevLn = [];
count = 0;
while numel(ln) < 1 || isnan(str2double(ln(1)))
    count = count + 1;
    prevLn = ln;
    ln = fgetl(fid);
end

if isempty(prevLn),
    error('Invalid syntax');
end


end


function [data, ln, count] = read_data(fid, ln, data, maxCount)

import mperl.split;
import misc.eta;

% Read protocol until an empty line is found
count = 0;
tinit = tic;
tmp = [];
while ~isempty(ln),
    
    count = count + 1;
    tmp = cellfun(@(x) str2double(x), split(',', ln));
    data(count, 1:numel(tmp)) = tmp;
    ln = fgetl(fid);
    
    if ~isempty(maxCount),
        misc.eta(tinit, maxCount, count);
    end
    
end
data(count+1:end,:) = [];
data(:, numel(tmp)+1:end) = [];


end