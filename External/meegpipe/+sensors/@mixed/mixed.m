classdef mixed < sensors.abstract_sensors
    % SENSORS.MIXED - Describes a sensor array with mixed sensor types
    %
    % ## Construction
    %
    % obj = sensors.mixed;
    % obj = sensors.mixed(obj1, obj2, ...)
    %
    % Where
    %
    % OBJ is a sensors.mixed object
    %
    % OBJ1, OBJ2, ... are sensors.sensorsobjects describing sensor arrays
    % of (possibly) different types
    %
    %
    % See also: sensors.sensors sensors.

    properties (SetAccess = 'private')
        Sensor;           % One or more sensor.sensor objects
    end
    
    % Consistency checks
    methods
        function obj = set.Sensor(obj, value)
            import exceptions.*;
            
            if isempty(value),
                obj.Sensor = [];
                return;
            end
            if ~iscell(value),
                value = {value};
            end
            
            isEmpty   = cellfun(@(x) isempty(x), value);
            value(isEmpty) = [];
            if isempty(value), 
                obj.Sensor = [];
                return;
            end
            isSensors = cellfun(@(x) isa(x, 'sensors.sensors'), value);
            if ~all(isSensors),
                throw(InvalidPropValue('Sensor', ...
                    'Must be a cell array of sensors.sensors objects'));
            end
            obj.Sensor = value;
        end
    end
    
    properties (Dependent)
        PhysDim;
    end
    
    % Dependent properties
    methods
        function value = get.PhysDim(obj)
            value = get_physdim(obj);
            if isempty(value), value = []; end
        end
    end
    
    % sensors.sensors interface
    methods
        labelsArray     = labels(obj)        
        nbSensors       = nb_sensors(obj)        
        sensorTypes     = types(obj)        
        [sArray, idx]   = sensor_groups(obj)      
        labels          = orig_labels(obj)  
        weigths         = get_eqweights(obj)
        obj             = subset(obj, idx)  
        xyz             = cartesian_coords(obj);
        count           = fprintf(fid, obj, varargin);       
    end
    
    % sensors.abstract_sensors
    methods
       pDim = get_physdim(obj)       
       obj  = set_physdim(obj, value)
    end
    
    % Conversion to other formats
    methods
        struct = fieldtrip(obj);
        struct = eeglab(obj);
    end
    
    % Other public methods
    methods
        layout  = layout2d(obj);
        layout  = layout3d(obj);
    end
    
    % Constructor
    methods
        function obj = mixed(varargin)
            
            if nargin < 1, return; end
           
            obj.Sensor = varargin;
        end
    end
end