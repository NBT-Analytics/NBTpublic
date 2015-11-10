function writeold(filename, data, sr)
% WRITE
% Writes data and/or events information to an .edf file
%
% write(fname, data, sr)
% write(fname, data, sr [, options])
%
% Where
%
% FNAME is a string with the full path name of the .edf file to be
% generated. If FNAME does not have file extension, .edf will be
% automatically attached to the file name. 
%
% DATA is an MxL numeric matrix that contains L samples of M signals.
%
% SR is the sampling rate.
%
% Optional arguments:
% 
% --patid <id>
%       The local patient identification (<= 80 characters). This string
%       must comply with the additional EDF+ specifications (see [2]). If
%       not provided, the patid will be 'X X X X'. Alternatively, the patid
%       can also be specified with a struct with fields code, sex, birthdate,
%       and name, which must comply with the EDF+ specifications (see [2]).
%       Additional fields are also allowed and will be attached at the end
%       of the four mandatory fields.
%
% --recid <id>
%       The local recording identification (<= 80 characters). This string
%       must comply with the additional EDF+ specification in [2]. If not
%       provided, the string 'Startdate X X X X'. The recid can also be
%       specified with a struct having (at least) the fields startdate,
%       code, investigator, and equipment. See [2] for details.
%
% --startdate <date>
%       Start date of recording (dd.mm.yy). By default, the startdate will
%       be the current date.
%
% --starttime <time>
%       Start time of recording (HH.MM.SS). By default, the starttime will
%       be the current time.
%
% --label <names_list>
%       A cell array with M signal labels. If a single label (a string) is
%       provided, it will be assigned to all M signals. Each label must be
%       a string <= 16 characters. If not provided, the labels 
%       {'e1', ..., 'eM'} will be used.
%
% --prefilt <filt_list>
%       A cell array with prefiltering or miscellaneous processing
%       settings for all M signals. If a single string is provided, it will
%       be assigned to all M signals. When specifying simple filters,
%       please follow the recommendations in [2].
%
% --transducer <type>
%       Type of transducer, e.g. 'AgAgCl electrode'. If a single string is
%       provided, all signals will be assumed as being obtained using the
%       same transducer. Signal-specific transducer types can be provided
%       using a cell array with M strings. 
%
% --header <headerobj>
%       An edfplus.header object containing all the information fields
%       given above and that could have been obtained e.g. via
%       edfplus.read. If the --header option is provided it will override
%       all other options above.
%
%
%
% More information:
%
% [2] http://www.edfplus.info/specs/edfplus.html#additionalspecs
%
%
% See also: EDFPLUS, edfplus.read, edfplus.header

import edfplus.globals;
import misc.process_arguments;

keySet = {...
    '--patid', ...
    '--recid', ...
    '--startdate', ...
    '--starttime', ...
    '--label', ...
    '--prefilt', ...
    '--transducer', ...
    '--header'
    };

MAX_REC_SIZE = 61440;

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
        % THIS IS NOT GENERAL! FIX IT LATER!! WHAT IF RECDURSAMPLES IS NO
        % INTEGER?
        recDurSec = 0.1*floor(recDurSec/0.1);
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
    
    
    
    % Data record
    % ---------------------------------------------------------------------
    
   
    nrec = 0;
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
    end       
catch ME
    fclose(fid);
    rethrow(ME);
    
    
end

fclose(fid);

end