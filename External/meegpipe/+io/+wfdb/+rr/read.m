function [rr, type] = read(filename)
% READ - Reads RR intervals file
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

fid = safefid(filename);

data = fid.textscan('%f %s');

rr   = data{1};
type = data{2};



end