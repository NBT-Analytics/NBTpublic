classdef edfplus < physioset.import.abstract_physioset_import
    % EDFPLUS - Imports EDF+ files
    %
    % ## Usage synopsis:
    %
    % import physioset.import.edfplus;
    % importer = edfplus('SignalType', {'ECG', 'EEG'});
    % data = import(edfplus, 'myfile.edf');
    % 
    %
    % ## Accepted (optional) construction arguments (as key/value pairs):
    %
    % * All key/value pairs accepted by abstract_physioset_import
    %
    %   SignalType : Cell array of strings. Default: {}, i.e. all types
    %       Subset of signal types to import. See io.edfplus.signal_types
    %
    %   Channels : Numeric array. Default: [], i.e. all channels
    %       Subset of channels to import.
    %
    %   EpochStartTime/EpochEndTime : Numeric scalar. Default: [], from beginning/end
    %       Start/End time of the data epoch to be imported, in seconds
    %
    %   EpochStartRec/EpochEndRec : Numeric scalar. Default: [], first/last record
    %       Index of the first/last record to be imported.
    %
    % ## Notes:
    %
    %   * A data range to be imported can be specified using either the
    %   EpochStartTime/EpochEndTime keys or the EpochStartRec/EpochEndRec keys, but not using
    %   both keys simultaneously.
    %
    % See also: abstract_physioset_import, io.edfplus.signal_types
   
    properties        
        
        SignalType;        
        Channels;
        EpochStartTime;
        EpochEndTime;
        EpochStartRec;
        EpochEndRec;
        
    end
    
    % Set methods / consistency checks
    methods
      
        function obj = set.SignalType(obj, value)
            
           import io.edfplus.signal_types;
           import misc.cell2str;
           import exceptions.*
           
           if ~iscell(value) && isempty(value),
               value = {};
           elseif ~iscell(value) && ischar(value),
               value = {value};
           elseif ~iscell(value),
               throw(InvalidPropValue('SignalType', ...
                   'Must be a cell array of strings'));
           end           
           
           flag = ismember(value, signal_types);
           
           if ~all(flag),               
               throw(InvalidPropValue('SignalType', ...
                   sprintf('Invalid signal type(s) %s', ...
                   cell2str(value(~flag)))));
           end       
           
           obj.SignalType = value;           
        end 
       
    end
    
    % physioset.import.import interface
    methods
        eegset_obj = import(obj, ifilename, varargin);        
    end
    
        
    % Constructor
    methods
        
        function obj = edfplus(varargin)
           import exceptions.*
          
           obj = obj@physioset.import.abstract_physioset_import(varargin{:}); 
           
           if (~isempty(obj.EpochStartTime) || ~isempty(obj.EpochEndTime)) && ...
                   (~isempty(obj.EpochStartRec) || ~isempty(obj.EpochEndRec)),
               throw(Inconsistent('Inconsistent epoch specifications'));
           end
           
           
        end
        
    end

    
end