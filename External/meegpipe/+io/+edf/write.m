function hdr = write(filename, hdr, data, varargin)
% WRITE - Writes data to an EDF file
%
% write(filename, hdr, data)
%
% hdr = write(filena, [], data)
%
% write(filename, hdr, data, 'key', value, ...)
%
%
% Where
%
% FILENAME is the name of the EDF file to be created
%
% HDR is a struct containing the EDF file header information. If left
% empty, a default header will be created using io.edf.default_header()
%
% DATA is a KxM data matrix with M samples and K channels
%
%
% ## Accepted key/value pairs:
%
% Zip7          : (logical) If set to true, the generated file will be
%                 compressed using 7zip. See notes below.
%                 Default: false
%
% BZip          : (logical) If set to true, the generated file will be
%                 compressed using BZip2. This can lead to file 3-4 times
%                 smaller. BZip will be used only if it is available in
%                 the system. See the notes below for more information.
%                 Default: false
%
% Verbose       : (logical) If set to false, no status messages will be
%                 displayed during execution. Default: true
%
% * All key/value pairs accepted by io.edf.default_header are also accepted
%   by this function.
%
%
%
% ## Notes:
%
% * Using a default header is not recommended as may prevent some
%   applications to handle correctly the generated EDF files, due to
%   unknown physical dimensions, sampling rates, channel labels,
%   etc. Providing the 'SamplingRate' and 'PhysDim' key/value pairs usually
%   is enough to generate a widely usable EDF file.
%
% * Signals with different sampling rates are not supported
%
% * A BZip2 compression/uncompression program must be installed in the
%   system for this function to be able to use it. BZip2 ships with most
%   Linux and Unix systems. You can get a Windows version in [3].
%   After installation you have to ensure that the BZip2 program location
%   is in the PATH environment variable.
%
% * The 7zip compression/uncompression program must be installed for 7zip
%   compression to be functional. See [4] and [5].
%
%
% ## References
%
% [1] http://www.edfplus.info/specs/edfplus.html#additionalspecs
%
% [2] http://www.edfplus.info/index.html
%
% [3] http://gnuwin32.sourceforge.net/packages/bzip2.htm
%
% [4] http://www.7-zip.org/
%
% [5] http://p7zip.sourceforge.net/
%
%
% See also: io.edf.default_header, io.edf

% Documentation: io_edf_write.txt
% Description: Writes data to an EDF file


import io.edf.default_header;
import misc.eta;
import misc.process_arguments;

MAX_REC_SIZE = 61440;

verboseLabel = '(io.edf:write) ';

opt.verbose = 1;
opt.bzip2   = false;
opt.zip7    = false;
[~, opt] = process_arguments(opt, varargin);

if size(data,1) > size(data,2),
    error('More channels than data samples?');
end

if isempty(hdr),
    hdr = default_header(size(data,1), varargin{:});
end

fid = fopen(filename, 'w', 'ieee-le');
try
    % Header
    % ---------------------------------------------------------------------
    
    fwrite(fid, '0       ', 'char');
    
    patId = repmat(' ', 1, 80);
    patId(1:numel(hdr.localPatientId)) = hdr.localPatientId;
    fwrite(fid, patId, 'char');
    
    recId = repmat(' ', 1, 80);
    recId(1:numel(hdr.localRecId)) = hdr.localRecId;
    fwrite(fid, recId, 'char');
    
    startDate = datestr(now, 'dd.mm.yy');
    fwrite(fid, startDate, 'char');
    
    startTime = datestr(now, 'HH.MM.SS');
    fwrite(fid, startTime, 'char');
    
    nSensors = size(data, 1);
    headerBytes = 8+80+80+8+8+8+44+8+8+4+...
        nSensors*16 + ...     % Sensor labels
        nSensors*80 + ...     % Transducer types
        nSensors*8  + ...     % Physical dimension (muV)
        nSensors*8  + ...     % Physical minimum
        nSensors*8  + ...     % Physical maximum
        nSensors*8  + ...     % Digital minimum
        nSensors*8  + ...     % Digital maximum
        nSensors*80 + ...     % Prefiltering HP:0.1Hz LP:75Hz
        nSensors*8  + ...     % nSensors*nr of samples in each data record
        nSensors*32;          % Reserved
    headerBytes = num2str(headerBytes);
    tmp = repmat(' ',1, 8);
    tmp(1:numel(headerBytes)) = headerBytes;
    fwrite(fid, tmp, 'char');
    
    fwrite(fid, repmat(' ', 1, 44), 'char'); % Reserved
    
    bytesSample = nSensors*2;
    recDurSamples = min(size(data,2), ...
        floor(MAX_REC_SIZE/bytesSample));
    recDurSec = recDurSamples/hdr.samplingRate;
    
    if ceil(recDurSec)*hdr.samplingRate*bytesSample < MAX_REC_SIZE,
        recDurSec = ceil(recDurSec);
        recDurSamples = recDurSec*hdr.samplingRate;
    else       
        while ceil(recDurSec)*hdr.samplingRate*bytesSample > MAX_REC_SIZE
            recDurSec = recDurSec/2;
        end
        recDurSec = ceil(recDurSec);
        recDurSamples = recDurSec*hdr.samplingRate;
        
    end
    
    nRec = ceil(size(data, 2)/recDurSamples);
    
    tmp = repmat(' ', 1, 8);
    tmp(1:numel(num2str(nRec))) = num2str(nRec);
    fwrite(fid, tmp, 'char');   % Number of data records
    
    tmp = repmat(' ', 1, 8);
    tmp(1:numel(num2str(recDurSec))) = num2str(recDurSec);
    fwrite(fid, tmp, 'char');   % Number of seconds in each record
    
    tmp = repmat(' ', 1, 4);
    tmp(1:numel(num2str(nSensors))) = num2str(nSensors);
    fwrite(fid, tmp, 'char');   % Number of sensors
    
    sensorLabel = '';
    physMin = '';
    physMax = '';
    
    if opt.verbose && opt.verbose < 2,
        fprintf([verboseLabel 'Calibrating...']);
    end
    tinit = tic;
    for sensorItr = 1:nSensors
        % Sensor labels
        tmp = repmat(' ', 1, 16);
        if numel(hdr.sensorLabel) >= sensorItr && ...
                ~isempty(hdr.sensorLabel{sensorItr}),
            tmp(1:numel(hdr.sensorLabel{sensorItr})) = ...
                hdr.sensorLabel{sensorItr};
        end
        sensorLabel = [sensorLabel tmp];   %#ok<*AGROW>
        
        % Physical minimum and maximum
        minVal = min(data(sensorItr, :));
        maxVal = max(data(sensorItr, :));
        
        % Calibration
        %minVal = floor(minVal);
        %maxVal = ceil(maxVal);
        data(sensorItr, :) = data(sensorItr, :) - minVal;
        data(sensorItr, :) = data(sensorItr, :)/(maxVal-minVal);
        data(sensorItr, :) = (hdr.digitalMax-hdr.digitalMin)*data(sensorItr, :) + hdr.digitalMin;
        data(sensorItr, isnan(data(sensorItr,:))) = 0;
        
        minVal = num2str(round(minVal));
        maxVal = num2str(round(maxVal));
        tmp = repmat(' ', 1, 8);
        tmp(1:numel(minVal)) = minVal;
        tmp = tmp(1:8);
        physMin = [physMin tmp];
        tmp = repmat(' ', 1, 8);
        tmp(1:numel(maxVal)) = maxVal;
        tmp =tmp(1:8);
        physMax = [physMax tmp];
        if opt.verbose && opt.verbose < 2,
            misc.eta(tinit, nSensors, sensorItr);
        end
    end
    
    if opt.verbose && opt.verbose < 2,
        fprintf(['\n\n' verboseLabel 'Writing header...']);
    end
    fwrite(fid, sensorLabel, 'char');
    
    tmp = repmat(' ', 1, 80);
    tmp(1:numel(hdr.transducerType)) = hdr.transducerType;
    fwrite(fid, repmat(tmp, 1, nSensors), 'char');
    
    tmp = repmat(' ', 1, 8);
    tmp(1:numel(hdr.physDim)) = hdr.physDim;
    fwrite(fid, repmat(tmp, 1, nSensors), 'char');
    
    fwrite(fid, [physMin physMax], 'char');
    
    tmp = repmat(' ', 1, 8);
    tmp(1:numel(num2str(hdr.digitalMin))) = num2str(hdr.digitalMin);
    fwrite(fid, repmat(tmp, 1, nSensors), 'char');
    tmp = repmat(' ', 1, 8);
    tmp(1:numel(num2str(hdr.digitalMax))) = num2str(hdr.digitalMax);
    fwrite(fid, repmat(tmp, 1, nSensors), 'char');
    
    tmp = repmat(' ', 1, 80);
    tmp(1:numel(hdr.preFiltering)) = hdr.preFiltering;
    fwrite(fid, repmat(tmp, 1, nSensors), 'char');
    
    tmp = repmat(' ', 1, 8);
    tmp2 = num2str(recDurSamples);
    tmp(1:numel(tmp2)) = tmp2;
    fwrite(fid, repmat(tmp, 1, nSensors), 'char');   % Number of samples in each record
    
    fwrite(fid, repmat(' ', 1, nSensors*32), 'char');
    
    if opt.verbose && opt.verbose < 2,
        fprintf('[done]\n\n');
    end
    
    % Data record
    % ---------------------------------------------------------------------
    if opt.verbose && opt.verbose < 2,
        fprintf([verboseLabel 'Writing %d data records...'], nRec);
    end
    nrec        = 0;
    nRecBy100   = floor(nRec/100);
    tinit       = tic;
    for sampleItr = 1:recDurSamples:size(data,2)
        if sampleItr+recDurSamples<size(data,2),
            tmp = data(:, sampleItr:sampleItr+recDurSamples-1);
        else
            tmp = zeros(size(data,1), recDurSamples);
            tmp2 = data(:, sampleItr:end);
            tmp(:, 1:size(tmp2,2)) = tmp2;
        end
        tmp = tmp';
        fwrite(fid, tmp(:), 'int16');
        nrec = nrec+1;
        if opt.verbose && ~mod(nrec, nRecBy100),
            eta(tinit, nRec, nrec);
        end
    end
    if opt.verbose && opt.verbose < 2,
        eta(tinit, nRec, nrec);
        fprintf('\n\n');
    end
catch ME
    fclose(fid);
    delete(filename);
    rethrow(ME);
end

fclose(fid);

if opt.bzip2,
    [status, ~] = system('bzip2 -h');
    if status,
        warning('io:edf:write:MissingBzip2', ...
            'bzip2 program is not available in this system: skipping BZip2 compression');
    else
        if opt.verbose && opt.verbose < 2,
            fprintf([verboseLabel 'Compressing %s...'], filename);
        end
        cmd = sprintf('bzip2 %s', filename);
        [status, msg] = system(cmd);
        if status,
            warning('io:edf:write:FailedSystemCall', ...
                'Something went wrong when calling bzip2: %s', msg);
        else
            delete(filename);
        end
        if opt.verbose && opt.verbose < 2,
            fprintf('[done]\n\n');
        end
    end
end

if opt.zip7,
    if isunix,
        [status, ~] = system('p7zip');
    else
        [status, ~] = system('7z');
    end
    if status,
        warning('io:edf:write:Missing7z', ...
            '7zip program is not available in this system: skipping 7zip compression');
    else
        if opt.verbose && opt.verbose < 2,
            fprintf([verboseLabel 'Compressing %s...'], filename);
        end
        if isunix,
            cmd = 'p7zip';
        else
            cmd = '7z';
        end
        [status, msg] = ...
            system(sprintf('%s a %s %s', cmd, [filename '.7z'], filename));
        if status,
            warning('io:edf:write:FailedSystemCall', ...
                'Something went wrong when calling %s: %s', cmd, msg);
        else
            delete(filename);
        end
        if opt.verbose && opt.verbose < 2,
            fprintf('[done]\n\n');
        end
    end
end

end