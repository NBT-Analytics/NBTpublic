classdef mux < sensors.abstract_sensors
    % MUX - Multiplexed sensors
    %
    %
    % 
    % See also: sensors
    
    properties (SetAccess = private)
       
        UmuxSensors;    % The underlying unmultiplexed sensors
        CycleDur;       % Duration of a MUX cycle, in ms
        NbSlots;        % Number of MUX slots
        CalibSlotIdx;   % Calibration slot indices
        SignalSlotIdx;   % Signal slot indices
        CalibValue;     % Calibration value
        
    end
    
    %% Global consistency check
    methods (Access = private)
        
        function check(obj)
            
            import exceptions.Inconsistent;
            
            if numel(obj.SignalSlotIdx) ~= nb_sensors(obj.UmuxSensors),
                throw(Inconsistent);
            end
            
            if ~isempty(intersect(obj.SignalSlotIdx, obj.CalibSlotIdx)),
                throw(Inconsistent(...
                    ['Indices of signal and calibration slots ' ...
                    'cannot overlap']));
            end
            
            if any(obj.CalibSlotIdx > obj.NbSlots) || ...
                    any(obj.SignalSlotIdx > obj.NbSlots)
               throw(Inconsistent); 
            end            
            
        end        
        
    end
    
    %% Local consistency checks
    methods 
       
        function obj = set.UmuxSensors(obj, value)
           
            import exceptions.*;
            if ~isa(value, 'sensors.sensors'),
                throw(InvalidPropValue('UmuxSensors', ...
                    'Must be a sensors.sensors object'));
            end
            obj.UmuxSensors = value;           
            
        end
        
        function obj = set.NbSlots(obj, value)
           
            import exceptions.*;
            import misc.isnatural;
            if numel(value) ~= 1 || ~isnatural(value),
                throw(InvalidPropValue('NbSlots', ...
                    'Must be a natural scalar'));
            end
            obj.NbSlots = value;
            
        end
        
        function obj = set.CycleDur(obj, value)
           
            import exceptions.*;
            
            if numel(value) ~= 1 || ~isnumeric(value) || value < eps,
                throw(InvalidPropValue('CycleDur', ...
                    'Must be a positive scalar'));
            end
            obj.CycleDur = value;
            
        end
        
        function obj = set.CalibSlotIdx(obj, value)
            
            import exceptions.*;
            import misc.isnatural;
            
            if ~isnatural(value),
                throw(InvalidPropValue('CalibSlotIdx', ...
                    'Must be (an array of) natural indices'));
            end
            
            obj.CalibSlotIdx = value;            
            
        end
        
        function obj = set.SignalSlotIdx(obj, value)
            
            import exceptions.*;
            import misc.isnatural;
            
            if ~isnatural(value),
                throw(InvalidPropValue('SignalSlotIdx', ...
                    'Must be (an array of) natural indices'));
            end
            
            obj.SignalSlotIdx = value;            
            
        end
        
        function obj = set.CalibValue(obj, value)
            
            import exceptions.*;
            
            if ~isnumeric(value) || ~isvector(value),
                throw(InvalidPropValue('CalibValue', ...
                    'Must be a numeric array'));
            end
            obj.CalibValue = value;           
            
        end
        
    end
    
    
    %% sensors.sensors interface
    methods
       
        function [cArray, cArrayIdx] = sensor_groups(obj)
           
            [cArray, cArrayIdx] = sensor_groups(obj.UmuxSensors);
            
        end
        
        function cellArray = labels(obj)
           
            cellArray = labels(obj.UmuxSensors);
            
        end
        
        function nbSensors = nb_sensors(obj)
           
            nbSensors = nb_sensors(obj.UmuxSensors);
            
        end
        
        function cellArray = types(obj)
            
            cellArray = types(obj.UmuxSensors);
            
        end
        
        function labels = orig_labels(obj)
            labels = orig_labels(obj.UmuxSensors);
        end
        
        function cellArray = get_physdim(obj)
            cellArray = get_physdim(obj.UmuxSensors);
        end
        
        function obj = set_physdim(obj, value)
            obj.UmuxSensors =  set_physdim(obj.UmuxSensors, value);
        end
        
        function w = get_eqweights(obj)
             w = get_eqweights(obj.UmuxSensors);
        end
        
        function obj = subset(obj, idx)
            obj.UmuxSensors = subset(obj.UmuxSensors, idx); 
            obj.NbSlots = numel(idx);
            [~, obj.CalibSlotIdx, idx] = intersect(idx, obj.CalibSlotIdx);
            obj.CalibValue = obj.CalibValue(idx);
        end
        
    end 
    
    %% Methods specific to mux sensors
    methods
       
        umuxData = unmultiplex(obj, muxData, fs);
        
    end
    
    %% Constructor
    methods
       
        function obj = mux(varargin)
            import misc.process_arguments;
            
            if nargin < 1, return; end
            
            opt.UmuxSensors = [];
            opt.CycleDur = [];
            opt.NbSlots = [];
            opt.CalibSlotIdx = [];
            opt.SignalSlotIdx = [];
            opt.CalibValue = [];
            
            [~, opt] = process_arguments(opt, varargin);
            
            fName = fieldnames(opt);
            for i = 1:numel(fName)
               obj.(fName{i}) = opt.(fName{i}); 
            end
            
            check(obj);
            
            
            
        end
        
        
    end
    
end