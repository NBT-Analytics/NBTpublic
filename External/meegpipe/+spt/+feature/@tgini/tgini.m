classdef tgini < spt.feature.feature & goo.verbose
    % TGINI - Gini index
    
    properties
        % Nonlinearity to be applied to the time-series before computing
        % the gini-index
        Nonlinearity = [];
    end
    
    methods
        % Consistency checks
        function obj = set.Nonlinearity(obj, value)
            import exceptions.InvalidPropValue;
            
            if isempty(value)
                obj.Nonlinearity = [];
                return;
            end
            
            if numel(value) ~= 1 || ~isa(value, 'function_handle'),
                throw(InvalidPropValue('Nonlinearity', ...
                    'Must be a function_handle'));
            end
            obj.Nonlinearity = value;
        end
        
        % spt.feature.feature interface
        function [featVal, featName] = extract_feature(obj, ~, tSeries, varargin)
            
            import misc.gini_idx;
            
            featName = [];
            
            featVal = nan(size(tSeries,1), 1);
            for i = 1:size(tSeries,1)
                thisTS = tSeries(i,:)';
                if ~isempty(obj.Nonlinearity),
                    thisTS = obj.Nonlinearity(thisTS);
                end
                featVal(i) = gini_idx(thisTS);
            end
            
        end
        
        % Constructor
        function obj = tgini(varargin)
            import misc.set_properties;
            
            if nargin < 1, return; end
            
            opt.Nonlinearity = [];            
            obj = set_properties(obj, opt, varargin);
            
        end
        
    end
    
    
    
end