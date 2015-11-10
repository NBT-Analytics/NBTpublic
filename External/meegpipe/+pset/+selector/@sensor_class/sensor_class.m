classdef sensor_class < pset.selector.abstract_selector
    % SENSOR_CLASS - Select one or more sensor classes and/or types
    %
    % ## Usage synopsis:
    %
    % import pset.*;
    %
    % % Create three independent sensor groups 
    % % (never mind about sensor labels)
    % sg1 = sensors.dummy(5);
    % sg2 = sensors.physiology('Label', {'ECG 1', 'ECG 2'});
    % sg3 = sensors.eeg.empty(10);
    % 
    % % Put them together into a mixed sensor array
    % mySensors = sensors.mixed(sg1, sg2, sg3);
    %
    % % Create sample physioset
    % X = randn(17, 1000);
    % data = import(pset.import.matrix(250, 'Sensors', mySensors), X);
    %
    % % Select only the ECG channels
    % mySelector = selector.sensor_class('Type', 'ECG');
    % select(mySelector, data);
    % 
    % % Must be OK
    % X1 = X(6:7,:);
    % import test.simple.ok;
    % ok(size(data,1) == 2 && max(abs(data(:) - X1(:)))<1e-3);
    %
    % % Clear selection and select now sensors of classes dummy and eeg
    % clear_selection(data);
    % mySelector = selector.sensor_class('Class', {'eeg', 'dummy'});
    % select(mySelector, data);
    %
    % % Must be OK
    % X2 = X([1:5 8:17], :);
    % ok(size(data,1) == 15 && max(abs(data(:) - X2(:)))<1e-3);
    %
    %
    % See also: selector 
    
    properties (SetAccess = private, GetAccess = private)
        
        SensorClass = {};
        SensorType  = {};
        Negated     = false;
        
    end
    
    methods
       
        function obj = set.SensorClass(obj, value)
           
            import exceptions.*
            
            if isempty(value), 
                obj.SensorClass = {};
                return;
            end
            
            if ischar(value), value = {value}; end
            
            if ~iscell(value) || ~all(cellfun(@(x) misc.isstring(x), value))
                throw(InvalidPropValue('SensorClass', ...
                    'Must be a cell array of strings'));
            end
            
            obj.SensorClass = lower(value);
            
        end
        
         function obj = set.SensorType(obj, value)
           
            import exceptions.*
            
            if isempty(value), 
                obj.SensorType = {};
                return;
            end
            
            if ischar(value), value = {value}; end
            
            if ~iscell(value) || ~all(cellfun(@(x) misc.isstring(x), value))
                throw(InvalidPropValue('SensorType', ...
                    'Must be a cell array of strings'));
            end
            
            obj.SensorType = lower(value);
            
        end
        
    end
    
    
     methods
        
        function obj = not(obj)
            
            obj.Negated = ~obj.Negated;
            
        end
        
        [data, emptySel, arg] = select(obj, data, remember);
        
        function disp(obj)
            
            import goo.disp_class_info;
            import mperl.join;
            
            disp_class_info(obj);
            
            if isempty(obj.SensorClass),
                fprintf('%20s : all classes\n',  'Class');
            else
                text = join(', ', obj.SensorClass);
                fprintf('%20s : %s\n', 'Class', text);
            end
            
            if isempty(obj.SensorType),
                fprintf('%20s : all types\n',  'Type');
            else
                text = join(', ', obj.SensorType);
                fprintf('%20s : %s\n', 'Type', text);
            end
            
            if obj.Negated,
                fprintf('%20s : yes\n', 'Negated');
            else
                fprintf('%20s : no\n', 'Negated');
            end
            
        end
        
    end
    
    % constructor
    methods
        
        function obj = sensor_class(varargin)
            
            import misc.process_arguments;
            
            obj = obj@pset.selector.abstract_selector(varargin{:});
            
            if nargin < 1, return; end
            
            opt.Class = [];
            opt.Type  = [];
            
            [~, opt] = process_arguments(opt, varargin);
            
            obj.SensorClass = opt.Class;
            obj.SensorType  = opt.Type;            
            
        end
        
        
    end
    
    
end