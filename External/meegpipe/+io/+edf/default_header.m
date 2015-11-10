function hdr = default_header(nbSensors, varargin)
% DEFAULT_HEADER - Default EDF header
%
% hdr = default_header(nbSensors);
%
% hdr = default_header(nbSensors, 'key', value, ...)
%
% 
% Where
%
% NBSENSORS is the number of sensors (i.e. the number of signals)
%
% 
% ## Accepted key/value pairs:
%
% SamplingRate  : (numeric) The sampling rate of the data. Default: 1
%
% PhysDim       : (char) The physical dimensions. For a list of common
%                 dimensions of common signal types see
%                 io.io.edf.signal_types. Default: 'na'
%
% PatientId     : (char) The patient ID. Default: ''
%
% RecId         : (char) The recording ID. Default: ''
%
% SensorLabel   : (cell) A cell array of sensor labels. 
%                 Default: repmat({'Unknown'}, K)
%
% DigitalMin    : (numeric) The maximum value of the digitalizer. 
%                 Default: 2047
%
% DigitalMax    : (numeric) The minimum value of the digitalizer
%                 Default: -2048
% 
% Transducer    : (char) The transducer type
%                  Default: ''
%
% PreFiltering  : (char) A string that can be used to specify any
%                 prefiltering that was applied to the data. It is
%                 advisable to follow the conventions in [1]
%
%
% ## References
%
% [1] http://www.edfplus.info/specs/edfplus.html#additionalspecs
%
% [2] http://www.edfplus.info/index.html
%
%
% See also: io.edf.write, io.edf

% Documentation: io_edf_default_header.txt
% Description: Default EDF header

import misc.process_arguments;

hdr.localPatientId = '';
hdr.localRecId = '';
hdr.samplingRate = 1;
hdr.sensorLabel = repmat({'Unknown'}, 1, nbSensors);
hdr.digitalMax = 2047;
hdr.digitalMin = -2048;
hdr.transducerType='';
hdr.physDim = 'na';
hdr.preFiltering = '';

[~, hdr] = process_arguments(hdr, varargin);

if ischar(hdr.sensorLabel),
    hdr.sensorLabel = repmat({hdr.sensorLabel}, 1, nbSensors);
end


end