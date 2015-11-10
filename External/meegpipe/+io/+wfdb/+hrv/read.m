function out = read(filename)
% READ - Reads HRV statistics file
%
%
%
%
% ## References:
%
% [1] http://www.physionet.org/tutorials/hrv/
%
% See also: wfdb

import safefid.safefid;
import misc.strtrim;

fid = safefid(filename);

% skip first line
fgetl(fid);
data = textscan(fid, '%[^=] = %f');

data{1}(:) = cellfun(@(x) strtrim(x), data{1}(:), 'UniformOutput', false);

% Remove problematic characters
data(:,1) = cellfun(@(x) regexprep(x, '\s', '_'), data(:,1), ...
    'UniformOutput', false);

out = mjava.hash;
out{data{1}{:}} = num2cell(data{2});


end