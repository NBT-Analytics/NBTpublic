classdef sensor_group_idx < pset.selector.abstract_selector
    % SENSOR_GROUP_IDX - Select one or more sensor groups
    %
    % ## Usage synopsis:
    %
    % import pset.*;
    % import test.simple.ok; % Only for testing assertions
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
    % data = import(pset.import.matrix('Sensors', mySensors), X);
    %
    % % Select only the first and third sensor groups
    % mySelector = selector.sensor_group_idx(1, 3);
    % select(mySelector, data);
    % 
    % % Must be OK
    % X = X([1:5, 11:15],:);
    % ok(size(data,1) == 10 && max(abs(data(:) - X(:)))<1e-3);
    %
    % See also: selector
    
    % Documentation: pkg_selector.txt
    % Description: Select one or more sensor groups
    
    
    %% IMPLEMENTATION .....................................................
    properties (SetAccess = private, GetAccess = private)
        
        SensorGroupIdx      = [];
        Negated             = false;
        
    end
    
    %% PUBLIC INTERFACE ...................................................
    
    % pset.selector.selector interface
    methods
        
        function obj = not(obj)
            
            obj.Negated = true;
            
        end
        
        function [data, emptySel, arg] = select(obj, data, remember)
            
            arg = [];
            
            if nargin < 3 || isempty(remember),
                remember = true;
            end
            
            rowSel = 1:nb_dim(data);
            
            [~, groupIdx] = sensor_groups(sensors(data));
            
            if ~isempty(obj.SensorGroupIdx),
                
                idx = intersect(1:numel(groupIdx), obj.SensorGroupIdx);
                selChan = cell2mat(groupIdx(idx));
                
                if obj.Negated,
                    
                    rowSel = setdiff(rowSel, selChan);
                    
                else
                    rowSel = intersect(rowSel, selChan);
                end
                
            end
            
            if isempty(rowSel),
                emptySel = true;
                return;
            else
                emptySel = false;
            end
            
            select(data, rowSel, [], remember);
            
        end
        
    end
    
    % Public methods declared and defined here
    
    methods
        
        function disp(obj)
            
            import goo.disp_class_info;
            import mperl.join;
            
            disp_class_info(obj);
            
            if isempty(obj.SensorGroupIdx),
                fprintf('%20s : all groups\n',  'SensorGroupIdx');
            else
                text = join(', ', obj.SensorGroupIdx);
                fprintf('%20s : %s\n', 'SensorGroupIdx', text);
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
        
        function obj = sensor_group_idx(varargin)
            
            obj = obj@pset.selector.abstract_selector(varargin{:});
            
            if nargin < 1, return; end
            
            obj.SensorGroupIdx = cell2mat(varargin);
            
        end
        
        
    end
    
end


