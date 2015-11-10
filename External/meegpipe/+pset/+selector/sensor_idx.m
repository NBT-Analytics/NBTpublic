classdef sensor_idx < pset.selector.abstract_selector
    % SENSOR_IDX - Select one or more sensors
    %
    % ## Usage synopsis:
    %
    % import pset.*;
    %
    % % Create three independent sensor groups 
    % % (never mind about sensor labels)
    % sg1 = sensors.dummy(5);
    % sg2 = sensors.dummy(5);
    % sg3 = sensors.dummy(5);
    % 
    % % Put them together into a mixed sensor array
    % mySensors = sensors.mixed(sg1, sg2, sg3);
    %
    % % Create sample physioset
    % X = randn(15, 1000);
    % data = import(pset.import.matrix, X, 'sensors', mySensors);
    %
    % % Select only the first 7 channels
    % mySelector = selector.sensor_idx(1:7);
    % select(mySelector, data);
    % 
    % % Must be OK
    % X = X(1:7,:);
    % import test.simple.ok;
    % ok(size(data,1) == 7 && max(abs(data(:) - X(:)))<1e-3);
    %
    % See also: selector 

    
    properties (SetAccess = private, GetAccess = private)
        
        SensorIdx = [];
        Negated   = false;
        
    end
    
    methods
        
        function obj = not(obj)
            
            obj.Negated = true;
            
        end
        
        function [data, emptySel, arg] = select(obj, data, remember)
            
            arg = [];
            
            if nargin < 3 || isempty(remember),
                remember = true;
            end
            
            if isempty(obj.SensorIdx), 
                emptySel = true;
                return;
            else
                emptySel = false;
            end
            
            selIdx = obj.SensorIdx;
            
            if obj.Negated,
                selIdx = setdiff(1:size(data,1), selIdx);
            end
            
            select(data, selIdx, [], remember);
            
        end
        
        function disp(obj)
            
            import goo.disp_class_info;
            import mperl.join;
            
            disp_class_info(obj);
            
            if isempty(obj.SensorIdx),
                fprintf('%20s : all groups\n',  'SensorIdx');
            else
                text = join(', ', obj.SensorIdx);
                fprintf('%20s : %s\n', 'SensorIdx', text);
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
        
        function obj = sensor_idx(idx, varargin)
            
            obj = obj@pset.selector.abstract_selector(varargin{:});
            
            if nargin < 1, return; end
            
            obj.SensorIdx = idx;
            
        end
        
        
    end
    
    
end
