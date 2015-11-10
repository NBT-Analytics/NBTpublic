classdef feature_aggregation < spt.feature.feature & goo.verbose
    % FEATURE_AGGREGATION - An aggregations of several features
    
    
    properties
        Aggregator  = @(x) mean(x); % A function_handle that aggregates features
        Features    = {}; % Cell array of features
    end
    
    % Consistency checks
    methods
        
        function obj = set.Features(obj, value)
            import exceptions.InvalidPropValue;
            
            if isempty(value),
                obj.Feature = {};
                return;
            end
            
            if ~iscell(value),
                value = {value};
            end
            
            if ~all(cellfun(@(x) isa(x, 'spt.feature.feature'), value)),
                throw(InvalidPropValue('Feature', ...
                    'Must be a cell array of spt.feature.feature'));
            end
            obj.Features = value;            
        end
        
        function obj = set.Aggregator(obj, value)
           import exceptions.InvalidPropValue;
           
           if isempty(value),
               obj.Aggregator = @(x) mean(x);
               return;
           end
           
           if ~isa(value, 'function_handle'),
               throw(InvalidPropValue('Aggregator', ...
                   'Must be a function_handle'));
           end
           obj.Aggregator = value;  
        end
        
    end
    
    methods
        
        % spt.feature.feature interface
        function [aggrFeatVal, featName] = extract_feature(obj, varargin)
            
            featVal = [];
            featName = [];
            for i = 1:numel(obj.Features)
                this = extract_feature(obj.Features{i}, varargin{:});
                featVal = [featVal this(:)]; %#ok<AGROW>
            end
            aggrFeatVal = nan(size(featVal,1), 1);
            for i = 1:size(featVal, 1)
                aggrFeatVal(i) = obj.Aggregator(featVal(i,:)); 
            end
        end
        
        % Constructor
        function obj = feature_aggregation(varargin)
            import misc.set_properties;
            
            if nargin < 1, return; end
            
            opt.Aggregator  = @(x) mean(x);
            opt.Features    = {};
            obj = set_properties(obj, opt, varargin);
          
        end
        
    end
    
    
    
end