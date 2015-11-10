function hdr = struct(varargin)

hdr.localPatientId = 'patid';
hdr.localRecId = 'recid';
hdr.startDate = '';
hdr.startTime = '';
hdr.samplingRate = [];
hdr.sensorLabel = cell(1, 257);
for i = 1:numel(hdr.sensorLabel)
    hdr.sensorLabel{i} = ['e' num2str(i)];    
end

hdr.transducerType = 'AgAgCl electrode';
hdr.physDim = 'uV';
hdr.digitalMin = -2048;
hdr.digitalMax = 2047;
hdr.preFiltering = 'HP:0.1Hz LP:30Hz';




end