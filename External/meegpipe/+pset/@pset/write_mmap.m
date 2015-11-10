function write_mmap(dat, filename, varargin)

import misc.process_arguments;
import misc.eta;
import misc.sizeof;

opt.precision = pset.globals.evaluate.Precision;
opt.chunksize = pset.globals.evaluate.LargestMemoryChunk;
opt.verbose   = true;
[~, opt] = process_arguments(opt, varargin);

opt.chunksize = floor(opt.chunksize/(sizeof(opt.precision)*size(dat,1))); % in samples
boundary = 1:opt.chunksize:size(dat,2);
if length(boundary)<2 || boundary(end) < size(dat,2),
    boundary = [boundary,  size(dat,2)+1];
else
    boundary(end) = boundary(end)+1;
end
n_chunks = length(boundary) - 1;

if exist(filename, 'file'),
    ME = MException('pset:pset:write_mmap:FileExists', ...
        'File %s exists', filename);
    throw(ME);
end

fid = fopen(filename, 'w');
tinit = tic;
try
    for chunk_itr = 1:n_chunks
        datsel = boundary(chunk_itr): (boundary(chunk_itr+1)-1);
        datwrite = dat(:, datsel);
        % Write the chunk into the output binary file
        fwrite(fid, datwrite(:), opt.precision);
        if opt.verbose && n_chunks>2,
            eta(tinit, n_chunks, chunk_itr);
        end
    end
catch ME
    if fid > 0,
        fclose(fid);
        delete(filename);
    end    
    rethrow(ME);
end
fclose(fid);


end