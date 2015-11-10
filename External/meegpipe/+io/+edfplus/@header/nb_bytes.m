function bytes = nb_bytes(ns)
import edfplus.globals;

ncVersion   = globals.evaluate.NbCharsVersion;
ncPatId     = globals.evaluate.NbCharsPatId;
ncRecId     = globals.evaluate.NbCharsRecId;
ncStartDate = globals.evaluate.NbCharsStartDate;
ncStartTime = globals.evaluate.NbCharsStartTime;
ncBytes     = globals.evaluate.NbCharsHeaderBytes;
ncReserved1 = globals.evaluate.NbCharsReserved1;
ncNbRec     = globals.evaluate.NbCharsNbRecords;
ncRecDur    = globals.evaluate.NbCharsRecDur;
ncNbSensors = globals.evaluate.NbCharsNbSensors;

ncSensor    = globals.evaluate.NbCharsSensor;
ncTrans     = globals.evaluate.NbCharsTransducer;
ncDim       = globals.evaluate.NbCharsDimension;
ncPhysMin   = globals.evaluate.NbCharsPhysMin;
ncPhysMax   = globals.evaluate.NbCharsPhysMax;
ncDigMin    = globals.evaluate.NbCharsDigMin;
ncDigMax    = globals.evaluate.NbCharsDigMax;
ncPreFilt   = globals.evaluate.NbCharsPreFilter;
ncNbSamples = globals.evaluate.NbCharsNbSamples;
ncReserved2 = globals.evaluate.NbCharsReserved2;
bytes = ncVersion + ncPatId + ncRecId + ncStartDate + ncStartTime + ...
    ncBytes + ncReserved1 + ncNbRec + ncRecDur + ncNbSensors + ...
    ns*(ncSensor + ncTrans + ncDim + ncPhysMin + ncPhysMax + ncDigMin + ...
    ncDigMax + ncPreFilt + ncNbSamples + ncReserved2);


    


end