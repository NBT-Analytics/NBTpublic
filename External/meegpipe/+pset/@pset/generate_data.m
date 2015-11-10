function obj = generate_data(type, nDims, nPoints, varargin)
% GENERATE_DATA Generates a pset object
%
%   OBJ = generate_data(TYPE, nDims, nPoints)
%
% Note 1: This function is an internal function that groups together the
% core functionality of functions such as randn, zeros, ones, nan, etc.
%
% See also: pset.pset

import pset.pset;
import misc.sizeof;
import misc.process_arguments;
import misc.isnatural;
import mperl.file.spec.catfile;
import pset.globals;
import pset.session;
import safefid.safefid;
import misc.unique_filename;

if strcmpi(type, 'matrix'),
    matrix  = nDims;
    nDims   = size(matrix, 1);
    varargin = [{nPoints} varargin];
    nPoints = size(matrix, 2);    
end

dataFileExt   = globals.get.DataFileExt;
opt.chunksize = globals.get.LargestMemoryChunk;
opt.filename  = []; % For backward compatibility. Use DataFile instead
opt.DataFile  = [];
opt.precision = globals.get.Precision;

[~, opt] = process_arguments(opt, varargin);

if isempty(opt.filename),
    opt.filename = opt.DataFile;
end

if isempty(opt.filename),
    filename = session.instance.tempname;
else
    [path, name] = fileparts(opt.filename);
    filename = catfile(path, name);
end

% Chunk size in samples
opt.chunksize = floor(opt.chunksize/(sizeof(opt.precision)*nDims));

nChunks = ceil(nPoints/opt.chunksize);
opt.chunksize = repmat(opt.chunksize, 1, nChunks);
if (nPoints - nChunks*opt.chunksize)<0,
    opt.chunksize(end) = (nPoints - (nChunks-1)*opt.chunksize(end));
end

fName = unique_filename([filename dataFileExt]);

[path, name] = fileparts(fName);

if ~exist(path, 'dir'),
    mkdir(path);
end

filename = catfile(path, name);

fid = safefid([filename dataFileExt], 'w');

if strcmpi(type, 'matrix'),
    fwrite(fid, matrix(:), opt.precision);
else
    for chunk_itr = 1:nChunks
        dat = eval([type '(nDims, opt.chunksize(chunk_itr))']);
        fwrite(fid, dat(:), opt.precision);
    end
end

clear fid; % Will close the file

obj = pset([filename dataFileExt], nDims, varargin{:});