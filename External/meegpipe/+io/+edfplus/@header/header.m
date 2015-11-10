classdef header
    % HEADER
    % Header class 
    %
    % obj = header(sr, nsamples);
    % obj = header(sr, nsamples, 'propName', 'propValue', ...);
    %
    % Where
    %
    % OBJ is a header object.
    %
    % SR is the sampling rate.
    %
    % NSAMPLES is the number of samples in the recording.
    %
    % Accepted arguments:
    %
    % --recid <obj>
    %       A recid object
    %
    % --patid <obj>
    %       A patid object
    %
    % --label <L>
    %       A cell array with M signal labels. Each label must be a string
    %       <= 16 characters. Altenatively, if L is a scalar, the labels 
    %       {'e1', 'e2', ..., 'eL'} will be used.
    %       
    %
    % --prefilt <cell>
    %       A cell array with prefiltering or miscellaneous processing
    %       settings for all M signals. If a single string is provided, it
    %       will be assigned to all M signals. When specifying simple 
    %       filters, please follow the recommendations in [1].    
    %
    % --transducer <type>
    %       Type of transducer, e.g. 'AgAgCl electrode'. If a single string
    %       is provided, all signals will be assumed as being obtained
    %       using the same transducer. Signal-specific transducer types can
    %       be provided using a cell array with M strings. 
    %
    % --tal <@tal object>
    %       A TAL (time-stamped annotations list) object that encodes
    %       events and stimuli as text annotations. Note that this
    %       parameter needs to be provided if the generated EDF+ file is 
    %       expected to contain any annotation.
    %
    %
    % More information:
    %
    % [1] http://www.edfplus.info/specs/edfplus.html#additionalspecs
    %
    %
    % See also: edfplus.recid, edfplus.patid, EDFPLUS
    
    properties
        RecordingId;
        PatientId;
        SignalSet;  
        StartDate;
        StartTime;
    end
   
    % Constructor
    methods
        function obj = header(varargin)
           import misc.process_arguments;
           
           keySet = {...
               'recid', ...
               'patid', ...
               'signalset', ...               
               'starttime', ...
               'startdate' ...
               };
           
           recid        = edfplus.recid;
           patid        = edfplus.patid;
           signalset    = edfplus.signalset;           
           startdate    = datestr(now, 'dd.mm.yy');
           starttime    = datestr(now, 'HH.MM.SS');
           
           eval(process_arguments(keySet, varargin));
           
           obj.RecordingId  = recid;
           obj.PatientId    = patid;
           obj.SignalSet    = signalset;     
           obj.StartDate    = startdate;
           obj.StartTime    = starttime;
           
        end
    end
    
    % Static factories
    methods (Static)
       obj = egi(ns); 
       obj = unknown(ns);
    end
    
    
    % Set access methods
    methods
        function obj = set.RecordingId(obj, value)
           if ~isa(value, 'edfplus.recid'),
              ME = MException('EDFPLUS:header:header:InvalidArgument', ...
                  'The ''RecordingId'' argument must be of class @recid');
              throw(ME);
           end
           obj.RecordingId = value;
        end
        
        function obj = set.PatientId(obj, value)
           if ~isa(value, 'edfplus.patid'),
              ME = MException('EDFPLUS:header:header:InvalidArgument', ...
                  'The ''PatientId'' argument must be of class @patid');
              throw(ME);
           end
           obj.PatientId = value;
        end
        
        function obj = set.SignalSet(obj, value)                   
           if ~isempty(value) && ~isa(value, 'edfplus.signalset'),
              ME = MException('EDFPLUS:header:header:InvalidArgument', ...
                  'Argument ''signalset'' must be of class @signalset');
              throw(ME);
           end           
           obj.SignalSet = value;         
        end       
        
        function obj = set.StartDate(obj, value)
            if isempty(regexpi(value, '^\d\d.\d\d.\d\d$')),
                ME = MException('EDFPLUS:header:header:InvalidArgument', ...
                     'Invalid start date ''%s''', value);
                throw(ME);
            end
            obj.StartDate = value;            
            
        end
        
        function obj = set.StartTime(obj, value)
            if isempty(regexpi(value, '^\d\d.\d\d.\d\d$')),
                ME = MException('EDFPLUS:header:header:InvalidArgument', ...
                     'Invalid start time ''%s''', value);
                throw(ME);
            end
            obj.StartTime = value;            
            
        end
    end
    
    
    % Public interface
    methods
       str = as_string(obj, nRec, recDur, spr);
    end
    
    % Static helper methods
    methods (Static)
       recLength = record_length(sr)
       bytes = nb_bytes(ns)
    end
    
    
    
    
end