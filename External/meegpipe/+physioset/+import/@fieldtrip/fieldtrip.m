classdef fieldtrip < physioset.import.abstract_physioset_import
    % FIELTRIP - Class for importing FIELTRIP files
    %
    % obj = physioset.import.fieldtrip('key', value, ...)
    %
    %
    % ## Accepted key/value pairs:
    %
    %   * See: help physioset.import.abstract_physioset_import
    %
    % See also: physioset.import. physioset.from_fieldtrip
    
    methods
        function obj = fieldtrip(varargin)
           obj = obj@physioset.import.abstract_physioset_import(varargin{:}); 
        end
    end
    
    % EEGC.import.interface
    methods
        eegset_obj = import(obj, ifilename, varargin);        
    end
    
    
    
    
end