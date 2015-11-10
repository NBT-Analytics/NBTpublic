function b = fieldtrip(a)
% FIELDTRIP - Converts to a Fieltrip structure
%
% fStructArray = fieldtrip(evArray)
%
%
% Where:
%
% EVARRAY is an array of pset.event objects
%
% FSTRUCTARRAY is an array of Fieltrip event structures
%
%
% See also: pset.event, physioset.event.struct, physioset.event.eeglab

% Documentation: class_pset_event.txt
% Description: Converts to Fieltrip structure

b = rmfield(struct(a),'dims');