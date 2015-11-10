function [sens, sr, hdr, ev, startDate, startTime, meta] = ...
    read_file(obj, fileName, psetFileName, verb, verbLabl)

import safefid.safefid;
import physioset.import.poly5;

if nargin < 3 || isempty(verbLabl), verbLabl = ''; end
if nargin < 2 || isempty(verb), verb = true; end

% The code in this function has been provided by TMSi

%% Read header
fid = safefid(fileName, 'r');
fidPset = safefid(psetFileName, 'w');

if verb,
    fprintf([verbLabl, 'Reading header ....']);
end

pos = 31;
fseek(fid, pos, -1);
version = fread(fid, 1, 'int16');
if version == 203
    frewind(fid);
    hdr.FID                   = fread(fid,[1 31],'uchar');
    hdr.VersionNumber         = fread(fid, 1,'int16');
elseif version == 204
    frewind(fid);
    hdr.FID                   = fread(fid, [1 32],'uchar');
    hdr.VersionNumber         = fread(fid, 1,'int16');
else
    error('Invalid Poly5 file (version %d)', version);
end
hdr.MeasurementName       = fread(fid, [1 81],'uchar');
hdr.FS                    = fread(fid, 1,'int16');
hdr.StorageRate           = fread(fid, 1,'int16');
hdr.StorageType           = fread(fid, 1,'uchar');
hdr.NumberOfSignals       = fread(fid, 1,'int16');
hdr.NumberOfSamplePeriods = fread(fid, 1,'int32');
hdr.EMPTYBYTES            = fread(fid, [1 4],'uchar');
hdr.StartMeasurement      = fread(fid, [1 14], 'uchar');
hdr.NumberSampleBlocks    = fread(fid, 1, 'int32');
hdr.SamplePeriodsPerBlock = fread(fid, 1, 'uint16');
hdr.SizeSignalDataBlock   = fread(fid, 1, 'uint16');
hdr.DeltaCompressionFlag  = fread(fid, 1, 'int16');
hdr.TrailingZeros         = fread(fid, [1 64], 'uchar');

% Signal description
for g=1:hdr.NumberOfSignals,
    hdr.description(g).SignalName        = fread(fid, [1 41], 'uchar');
    hdr.description(g).Reserved          = fread(fid, [1 4], 'uchar');
    hdr.description(g).UnitName          = fread(fid, [1 11], 'uchar');
    hdr.description(g).UnitLow           = fread(fid, 1, 'float32');
    hdr.description(g).UnitHigh          = fread(fid, 1, 'float32');
    hdr.description(g).ADCLow            = fread(fid, 1, 'float32');
    hdr.description(g).ADCHigh           = fread(fid, 1, 'float32');
    hdr.description(g).IndexSignalList   = fread(fid, 1, 'int16');
    hdr.description(g).CacheOffset       = fread(fid, 1, 'int16');
    hdr.description(g).Reserved2         = fread(fid, [1 60], 'uchar');
    
    % conversion of char values (to right format)
    hdr.description(g).SignalName = char(hdr.description(g).SignalName(2:hdr.description(g).SignalName(1)+1));
    hdr.description(g).UnitName   = char(hdr.description(g).UnitName(2:hdr.description(g).UnitName(1)+1));
end  %for

%conversion to char of text values
hdr.FID               = char(hdr.FID);
hdr.MeasurementName   = char(hdr.MeasurementName(2:hdr.MeasurementName(1)+1));

if verb, fprintf('[done]\n\n'); end

%% Read signal values

if verb,
    fprintf([verbLabl, 'Reading signal values ...']);
end

NB = hdr.NumberSampleBlocks;
SD = hdr.SizeSignalDataBlock;
NS = hdr.NumberOfSignals;

if verb,
    clear +misc/eta;
    NBBy100 = floor(NB/100);
    tinit = tic;
end
for g=1:NB;
    if hdr.VersionNumber == 203
        pos = 217 + NS*136 + (g-1) *(86+SD);
    else
        pos = 218 + NS*136 + (g-1) *(86+SD);
    end
    fseek(fid, pos,-1);
    
    hdr.block(g).PI = fread(fid, 1, 'int32'); %period index
    fread(fid, 4,'uchar'); %reserved for extension of previous field to 8 bytes
    hdr.block(g).BT = fread(fid, 14/2, 'int16'); %dostime
    fread(fid, 64, 'uchar'); %reserved
    data = fread(fid, SD/4, 'float32');
    
    fwrite(fidPset, data(:), obj.Precision);
    
    if verb && ~mod(g, NBBy100),
        misc.eta(tinit, NB, g);
    end
end %for

datum = hdr.block(1,1).BT;
hdr.measurementdate = [num2str(datum(3),'%02.0f') '-' ...
    num2str(datum(2),'%02.0f') '-' num2str(datum(1),'%02.0f')];
hdr.measurementtime = [num2str(datum(5),'%02.0f') ':' ...
    num2str(datum(6),'%02.0f') ':' num2str(datum(7),'%02.0f')];

nbSamples = SD/(4*NS/2);
ts = nbSamples/hdr.FS;
th = floor(ts / 3600);
tm = floor(ts/60 - th*60);
tss = floor(ts - th*3600 - tm * 60);
hdr.measurementduration = [num2str(th,'%02.0f') ':' ...
    num2str(tm,'%02.0f') ':' num2str(tss,'%02.0f')];

startTime = datenum(hdr.measurementtime);
startDate = datenum(hdr.measurementdate);

if verb,
    fprintf('[done]\n\n');
    clear +misc/eta;
end

% Events are read with read_events()
ev = [];
sr = hdr.FS;

% Maybe the sensors are provided as a .sensors mat file
sens = [];
[path, name] = fileparts(fileName);
sensorsFName = [path, name, '.sensors'];
if exist(sensorsFName, 'file'),
    if verb,
        fprintf([verbLabl, 'Found sensors information file: %s ...'], sensorsFName);
    end
    tmp = load(sensorsFName, '-mat');
    if ~isempty(tmp) && isstruct(tmp),
        fNames = fieldnames(tmp);
        if numel(fNames) > 1,
            error('File %s does not contain the expected sensors structure', ...
                sensorsFName);
        end
        sens = tmp.(fNames{1});
        if ~isa(sens, 'sensors.physiology'),
            error('File %s should contain a sensors.physiology object', ...
                sensorsFName);
        end
    end
end

if isempty(sens),
    sens = poly5.descriptions2sensors(hdr.description);
end

end