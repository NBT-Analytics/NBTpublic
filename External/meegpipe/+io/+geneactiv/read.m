function [data, time, hdr] = read(fname, varargin)
% read - Reads geneactiv .bin files
%
% ````matlab
% [data, time, hdr] = read(fname)
% [data, time, hdr] = read(fname, 'key1', 'key2',...)
% ````
%
% Where
%
% __fname__ is the full path name of the file to be read.
%
% __hdr__ is a struct with header information. 
%
% __time__ is an Nx1 vector of measurement times. The times are expressed
% as serial date numbers (see help datenum).
%
% __data__ is the data matrix, with rowwise data samples.
%
% 'key1', 'key2' are names of page properties that should be extracted (and
% interpolated) from each data page. 
%
%
% See also io.geneactiv

[headerInfo, time, xyz, light, button, prop_val] = ...
    io.geneactiv.binread(fname, varargin{:});


data = [xyz light button prop_val];

hdr.info = headerInfo;
hdr.label = [{'X', 'Y', 'Z', 'light', 'button'} varargin];

end

