classdef signalset
    % SIGNALSET
    % @signalset class
    %
    % obj = signalset(signalArray);
    %
    % Where
    %
    % OBJ is a @signalset object
    %
    % SIGNALARRAY is an array of @signal objects
    %    
    %
    % Static factories:
    %
    % egi(nbSensors)
    %       Set of EEG signals acquired with an EGI net of NBSENSORS
    %       channels
    %
    %
    % More information:
    %
    % [1] http://www.edfplus.info/specs/edftexts.html
    %
    %
    % See also: edfplus.header, EDFPLUS
    
    properties (SetAccess = private)
        Signal;
    end
    
    properties (Dependent)        
        nSignals;
    end
      
       
    % Constructor
    methods
        function obj = signalset(signal)
            if nargin < 1, return; end               
            
            obj.Signal = signal;            
        end
    end
    
    % Consistency checks: set methods
    methods
        function obj = set.Signal(obj, value)                      
           if ~isa(value, 'edfplus.signal')
              ME = MException('label:error', ...
                  'The ''Signal'' property must be of class @signal'); 
              throw(ME);
           end           
           
           obj.Signal = value;
        end       
    end    
    
    methods
        function value = get.nSignals(obj)
           value = numel(obj.Signal);
        end           
    end    
   
    % Helper private methods
    methods 
        function str = as_string(obj) 
            import edfplus.globals;
            ncSensor        = globals.evaluate.NbCharsSensor;
            sensorLabel     = repmat(' ', 1, ncSensor*numel(obj.Signal));
            ncTransducer    = globals.evaluate.NbCharsTransducer;
            transLabel      = repmat(' ', 1, ncTransducer*numel(obj.Signal));
            ncDim           = globals.evaluate.NbCharsDimension;
            dimLabel        = repmat(' ', 1, ncDim*numel(obj.Signal));
            ncPhysMin       = globals.evaluate.NbCharsPhysMin;
            physMinLabel    = repmat(' ', 1, ncPhysMin*numel(obj.Signal));
            ncPhysMax       = globals.evaluate.NbCharsPhysMax;
            physMaxLabel    = repmat(' ', 1, ncPhysMax*numel(obj.Signal));
            ncDigMin        = globals.evaluate.NbCharsDigMin;
            digMinLabel     = repmat(' ', 1, ncDigMin*numel(obj.Signal));
            ncDigMax        = globals.evaluate.NbCharsDigMax;
            digMaxLabel     = repmat(' ', 1, ncDigMax*numel(obj.Signal));
            ncPreFilter     = globals.evaluate.NbCharsPreFilter;
            preFiltLabel    = repmat(' ', 1, ncPreFilter*numel(obj.Signal));
            for i = 1:numel(obj.Signal)
               thisObj = obj.Signal(i);
               sensorLabel((i-1)*ncSensor+1:i*ncSensor)  = ...
                   sensor_label(thisObj);
               transLabel((i-1)*ncTransducer+1:i*ncTransducer)  = ...
                   transducer_label(thisObj);
               dimLabel((i-1)*ncDim+1:i*ncDim)  = ...
                   dimension_label(thisObj);
               physMinLabel((i-1)*ncPhysMin+1:i*ncPhysMin)  = ...
                   physmin_label(thisObj);
               physMaxLabel((i-1)*ncPhysMax+1:i*ncPhysMax)  = ...
                   physmax_label(thisObj);
               digMinLabel((i-1)*ncDigMin+1:i*ncDigMin)  = ...
                   digmin_label(thisObj);
               digMaxLabel((i-1)*ncDigMax+1:i*ncDigMax)  = ...
                   digmax_label(thisObj);
               preFiltLabel((i-1)*ncPreFilter+1:i*ncPreFilter)  = ...
                   prefilter_label(thisObj);     
            end             
            str = [...
                sensorLabel ...
                transLabel ...
                dimLabel ...
                physMinLabel ...
                physMaxLabel ...
                digMinLabel ...
                digMaxLabel ...
                preFiltLabel ...
                ];
        end
              
    end
    
    % Statis factories
    methods (Static)
       obj = egi(nsensors); 
    end
    
    % Static methods
    methods (Static)
        [type, dim, descr] = signal_types(varargin);        
    end
    
    


end