function y = isedfplus(filename)
% ISEDFPLUS Returns true for EDF+ files and false otherwise
%
%   Y = isedfplus(FILENAME)
%
% See also: EDFPLUS/read

import io.edfplus.isedfplus;
import io.edfplus.read;
import misc.strtrim;

if nargin < 1,     
    error('EDFPLUS:isedfplus:invalidInput', ...
        'A file name is expected as input argument.');
end

[~, ~, ext] = fileparts(filename);

if ~strcmpi(ext, '.edf'),
    y = false;
    return;
end

hdr = read(filename,'verbose',false);

switch lower(strtrim(hdr.edfplus_type))
    case {'edf+c','edf+d'},
        y = true;
    otherwise
        y = false;
end