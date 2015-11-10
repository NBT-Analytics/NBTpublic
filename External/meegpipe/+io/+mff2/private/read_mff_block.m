function [hdr, dat] = read_mff_block(fid, prevhdr, chanidx)
% Borrowed from Fieldtrip!!
% Modified so that a matrix is always returned, instead of a cell array
% Removed the action argument

if nargin < 3,
    chanidx = [];
end

if nargin<2
    prevhdr = [];
end

%-Endianness
endian = 'ieee-le';

% General information
hdr.version = fread(fid, 1, 'int32', endian);

if feof(fid),
    hdr = [];
    dat = [];
    return;
end

if hdr.version==0
    % the header did not change compared to the previous one
    % no additional information is present in the file
    % the file continues with the actual data
    hdr = prevhdr;
    hdr.version = 0;
else
    hdr.headersize = fread(fid, 1, 'int32', endian);
    hdr.datasize = fread(fid, 1, 'int32', endian);
    hdr.nsignals = fread(fid, 1, 'int32', endian);
    
    % channel-specific information
    hdr.offset = fread(fid, hdr.nsignals, 'int32', endian);
    
    % signal depth and frequency for each channel
    for i = 1:hdr.nsignals
        hdr.depth(i)   = fread(fid, 1, 'int8', endian);
        hdr.fsample(i) = fread(fid, 1, 'bit24', endian); %ingnie: is bit24 the same as int24?
    end
    
    %-Optional header length
    hdr.optlength   = fread(fid, 1, 'int32', endian);
    
    if hdr.optlength
        hdr.opthdr.EGItype  = fread(fid, 1, 'int32', endian);
        hdr.opthdr.nblocks  = fread(fid, 1, 'int64', endian);
        hdr.opthdr.nsamples = fread(fid, 1, 'int64', endian);
        hdr.opthdr.nsignals = fread(fid, 1, 'int32', endian);
    else
        hdr.opthdr = [];
    end
    
    % determine the number of samples for each channel
    hdr.nsamples = diff(hdr.offset);
    % the last one has to be determined by looking at the total data block length
    hdr.nsamples(end+1) = hdr.datasize - hdr.offset(end);
    % divide by the number of bytes in each channel
    hdr.nsamples = hdr.nsamples(:) ./ (hdr.depth(:)./8);
    
end % reading the rest of the header

% Is it a funny block with different samples/precisions for diff. signals
diffSample    = any(diff(hdr.nsamples));
diffPrecision = any(diff(hdr.depth));

if isempty(chanidx),
    chanidx = 1:hdr.nsignals;
end

currchan = 1;
maxnsamples = max(hdr.nsamples);
if diffPrecision || diffSample,
    dat = nan(numel(chanidx), maxnsamples);
    for i = 1:hdr.nsignals
        switch hdr.depth(i) % length in bit
            case 16
                datatype = 'int16';
            case 32
                datatype = 'single';
            case 64
                datatype = 'double';
        end % case
        tmp = fread(fid, [1 hdr.nsamples(i)], datatype);
        
        % Upsample if necessary
        if hdr.nsamples(i) < maxnsamples,
            tmp = upsample(tmp, maxnsamples/hdr.nsamples(i));
        end
        
        if ismember(chanindx,i) %only keep channels that are requested
            dat(currchan, :) = tmp;
            currchan = currchan + 1;
        end
    end % for
    
else
    % Easy case, same sampling rate, same precision, read faster
    switch hdr.depth(1) % length in bit
        case 16
            datatype = 'int16';
        case 32
            datatype = 'single';
        case 64
            datatype = 'double';
    end % case
    dat = fread(fid, [hdr.nsamples(1), hdr.nsignals], datatype);
    dat = dat(:, chanidx)';
end

