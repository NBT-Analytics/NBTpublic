function [hdr, dat, prevhdr] = read_mff_bin(fid, begBlock, endBlock, idx, prevHdrIn)
% READ_MFF_BIN - Reads .mff binary files
%
% This is just a clean-up of function read_mff_bin included in the
% Fieldtrip toolbox.
%
%
%

import misc.process_arguments;

DEF_NBBLOCKS = 500;
MAX_NBBLOCKS = 10000;

if ~isempty(prevHdrIn),
    prevhdr = prevHdrIn;
else
    prevhdr = [];
end

if ~isempty(endBlock),
    nbblocks = endBlock - begBlock+ 1;
else
    nbblocks = [];
end

if nbblocks < 1,
    hdr = [];
    dat = [];
    return;
end

% Skip initial blocks
if begBlock> 1,
    hdr   = skip_mff_block(fid, begBlock-1, prevhdr);
    prevhdr = hdr;
end

% Read first block
[prevhdr, dat1] = read_mff_block(fid, prevhdr, idx);

% There are not as many blocks in this file
if isempty(prevhdr),
    hdr = [];
    dat = [];
    return;
end

hdr(1) = prevhdr;


% A good guess on how much data we are going to read
nsamples = size(dat1,2);
if ~isempty(nbblocks) && nbblocks < MAX_NBBLOCKS,
    dat = zeros(size(dat1,1), nbblocks*nsamples);
else
    dat = zeros(size(dat1,1), DEF_NBBLOCKS*nsamples);
end

dat(:,1:size(dat1,2)) = dat1;
beginSample = size(dat1,2)+1;
i = 2;
while i <= nbblocks,
    [prevhdr, thisDat] = ...
        read_mff_block(fid, prevhdr, idx);
    
    if isempty(prevhdr),
        % We have reached the end of the file
        break;
    end
    
    dat(:, beginSample:beginSample+size(thisDat,2)-1) = thisDat;
    beginSample = beginSample + size(thisDat,2);
    hdr(i) = prevhdr;
    i = i + 1;    
end

% assign the output variable (we have read i-1 blocks)
dat(:, beginSample:end) = [];
hdr(i:end) = [];



end