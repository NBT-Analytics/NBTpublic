function hdr = skip_mff_block(fid, nbBlocks, prevHdr)


%-Endianness
endian = 'ieee-le';

hdr = [];

for j = 1:nbBlocks  
    
    % General information
    version = fread(fid, 1, 'int32', endian);
    if feof(fid),
        return;
    end
    
    hdr.version = version;
    
    if hdr.version==0
        % the header did not change compared to the previous one
        % no additional information is present in the file
        % the file continues with the actual data
        hdr = prevHdr;
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
    
    fseek(fid, hdr.datasize, 'cof');
   
    prevHdr = hdr;
    
end


end