classdef topo_ratio < spt.feature.feature & goo.verbose
    % TOPO_RATIO - Topographical ratio
    
    properties
        
        Symmetrical = false;
        SensorsDen = [];        % A regular expression or cell array of labels
        SensorsNumLeft  = [];   % A regular expression or cell array of labels
        SensorsNumRight = [];   % A regular expression or cell array of labels
        SensorsNumMid   = [];       
        FunctionDen = @(x) sum(x.^2);
        FunctionNum = @(x) sum(x.^2);
        
    end
    
    % Consistency checks
    methods
        
        function obj = set.SensorsDen(obj, value)
            import exceptions.InvalidPropValue;
            
            if isempty(value),
                obj.SensorsDen = [];
                return;
            end
            
            if iscell(value) && ~all(cellfun(@(x) ischar(x), value)),
                throw(InvalidPropValue('SensorsDen', ...
                    'Must be a cell array of strings (sensor labels)'));
            elseif ~iscell(value) && ~ischar(value),
                throw(InvalidPropValue('SensorsDen', ...
                    'Must be a string (a regular expression)'));
            end
            
            obj.SensorsDen = value;
        end
        
        function obj = set.FunctionDen(obj, value)
            import exceptions.InvalidPropValue;
            
            if isempty(value),
                obj.FunctionDen = @(x,y) sum(x.^2);
                return;
            end
            
            if ~isa(value, 'function_handle'),
                throw(InvalidPropValue('FunctionDen', ...
                    'Must be a function_handle'));
            end
            
            obj.FunctionDen = value;
        end
        
        function obj = set.FunctionNum(obj, value)
            import exceptions.InvalidPropValue;
            
            if isempty(value),
                obj.FunctionNum = @(x,y) sum(x.^2);
                return;
            end
            
            if ~isa(value, 'function_handle'),
                throw(InvalidPropValue('FunctionNum', ...
                    'Must be a function_handle'));
            end
            
            obj.FunctionNum = value;
        end
        
    end
    
    % Static constructors
    methods (Static)
        
        myCrit = eog_egi256_hcgsn1(varargin);
        
    end
    
    
    methods
        
        [idx, featName] = extract_feature(obj, sptObj, tSeries, raw, varargin);
        
        % Constructor
        function obj = topo_ratio(varargin)
            import misc.set_properties;
            
            if nargin < 1, return; end
            
            opt.Symmetrical = false;
            opt.SensorsDen = [];        % A regular expression or cell array of labels
            opt.SensorsNumLeft  = [];   % A regular expression or cell array of labels
            opt.SensorsNumRight = [];   % A regular expression or cell array of labels
            opt.SensorsNumMid   = [];
            opt.FunctionDen = @(x) sum(x.^2);
            opt.FunctionNum = @(x) sum(x.^2);
            obj = set_properties(obj, opt, varargin);
            
        end
        
    end
    
    
    
end