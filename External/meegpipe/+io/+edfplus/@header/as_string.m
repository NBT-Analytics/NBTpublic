function str = as_string(obj, nRec, recDur, spr)
import edfplus.globals;
import edfplus.header;
if nargin < 2 || isempty(nRec),
    nRec = -1;
end
ncVersion     = globals.evaluate.NbCharsVersion;

ncHeaderBytes = globals.evaluate.NbCharsHeaderBytes;
headerBytes = num2str(header.nb_bytes(obj.SignalSet.nSignals));
headerBytesStr = repmat(char(0), 1, ncHeaderBytes);
if numel(headerBytes) > ncHeaderBytes,
    ME = MException('EDFPLUS:header:header:TooLargeHeader', ...
        'Too large header!');
    throw(ME);
end
headerBytesStr(1:numel(headerBytes)) = headerBytes;

ncNbRecords   = globals.evaluate.NbCharsNbRecords;
nRec = num2str(nRec);
nRecStr = repmat(char(0), 1, ncNbRecords);
if numel(nRec) > ncNbRecords,
    ME = MException('EDFPLUS:header:header:TooManyRecords', ...
        'Too many records!');
    throw(ME);
end
nRecStr(1:numel(nRec)) = nRec;

ncRecDur   = globals.evaluate.NbCharsRecDur;
recDur     = num2str(recDur);
recDurStr  = repmat(char(0), 1, ncRecDur);
if numel(recDur) > ncRecDur,
    ME = MException('EDFPLUS:header:header:TooManyRecords', ...
        'Too many records!');
    throw(ME);
end
recDurStr(1:numel(recDur)) = recDur;

ns      = obj.SignalSet.nSignals;
ncNs    = globals.evaluate.NbCharsNbSensors;
ns      = num2str(ns);
nsStr   = repmat(char(0), 1, ncNs);
if numel(ns) > ncNs,
    ME = MException('EDFPLUS:header:header:TooManyRecords', ...
        'Too many records!');
    throw(ME);
end
nsStr(1:numel(ns)) = ns;

ncSpr   = globals.evaluate.NbCharsNbSamples;
spr     = num2str(spr);
sprStr  = repmat(char(0), 1, ncNs);
if numel(spr) > ncSpr,
    ME = MException('EDFPLUS:header:header:TooManySamplesPerRecord', ...
        'Too many samples per record!');
    throw(ME);
end
sprStr(1:numel(spr)) = spr;

str = [...
    repmat(char(0), 1, ncVersion) ...
    as_string(obj.PatientId) ...
    as_string(obj.RecordingId) ...
    obj.StartDate ...
    obj.StartTime ...
    headerBytesStr ...
    repmat(char(0), 1, 44) ...
    nRecStr ...
    recDurStr ...
    nsStr ...
    as_string(obj.SignalSet) ...
    sprStr ...
    repmat(char(0), 1, obj.SignalSet.nSignals) ...
    ];

end
