classdef sgini < spt.feature.feature & goo.verbose
    % SGINI - Spatial gini index
    
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
        function [featVal, featName] = extract_feature(obj, sptObj, varargin)            
            
            import misc.gini_idx;
            
            featName = [];
            
            M = bprojmat(sptObj);
            
            if ~isempty(obj.Nonlinearity),
                M = obj.Nonlinearity(M);
            end
            
            featVal = gini_idx(M);
            
            featVal = featVal(:);
            
        end
        
         % Constructor
        function obj = sgini(varargin)
            import misc.set_properties;
            
            if nargin < 1, return; end
            
            opt.Nonlinearity = [];            
            obj = set_properties(obj, opt, varargin);
            
        end
        
    end
end