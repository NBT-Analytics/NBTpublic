function [data, fsample, fidOut] = read_data(filename, begBlock, endBlock, sigIdx, ...
    keepopen, seq)

import misc.dir;

persistent fid;
persistent prevHdr;
persistent binFiles;

if isempty(binFiles),
    binFiles = dir(filename, '^signal.+\.bin$', true);    
    if isempty(binFiles)
        ME = MException('mff:read:NoBinaryData', ...
            'File %s does not contain any binary data', filename);
        throw(ME);
    else
        binFiles = sort(binFiles);
    end
    
    binFiles = cellfun(@(x) mperl.file.spec.catfile(filename, x), ...
        binFiles, 'UniformOutput', false);
    
end

% Read the signals binary data
nSignals   = numel(binFiles);
if nSignals > 1,
    data = cell(nSignals,1);
end

fsample = nan(1, nSignals);

% FIDs to all binary files
if isempty(fid),
    fid = nan(1, nSignals);
end
if isempty(prevHdr),
    prevHdr = cell(1, nSignals);
end
for sigItr = 1:nSignals
    if isnan(fid(sigItr)),
        fid(sigItr) = fopen(binFiles{sigItr}, 'r');
    end
    
    if seq,
        % We are reading the file sequentially
        endBlock = endBlock-begBlock+1;
        begBlock = 1;
    end
    
    try
        [signalHdr, signalData, prevHdr{sigItr}] = ...
            read_mff_bin(fid(sigItr), ...
            begBlock, ...
            endBlock, ...
            sigIdx, ...
            prevHdr{sigItr});
    catch ME
        if strcmp(ME.identifier, 'MATLAB:badfid_mx')
            fid(sigItr) = fopen(binFiles{sigItr}, 'r');
            try
                [signalHdr, signalData, prevHdr{sigItr}] = ...
                    read_mff_bin(fid(sigItr), ...
                    begBlock, ...
                    endBlock, ...
                    sigIdx, ...
                    prevHdr{sigItr});
            catch ME
                fclose(fid(sigItr));
                clear +io/+mff2/read_data;
                throw(ME);
            end
        else
            fclose(fid(sigItr));
            clear +io/+mff2/read_data;
            throw(ME);
        end
    end
    
    % Close the file unless we are planning to keep reading the file
    if ~keepopen,
        fclose(fid(sigItr));
        clear +io/+mff2/read_data; % To clear static variables
    end
    
    if nSignals > 1,
        data{sigItr} = signalData;
    else
        data = signalData;
    end
end

if keepopen,
    fidOut = fid;
else  
    fidOut = [];
end

if ~isempty(signalHdr),
    fsample = signalHdr(1).fsample(1);
end

end