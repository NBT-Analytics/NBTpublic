function n_bytes = sizeof(precision)
% SIZEOF Returns the number of bytes for a given numeric precision
%
%   N_BYTES = sizeof(PRECISION) where PRECISION is a char array 
%   that identifies a numeric type in MATLAB. E.g. 'single', 'double', etc.

tmp = eval([precision '(0)']); %#ok<NASGU>
tmp = whos('tmp');
n_bytes = tmp.bytes;