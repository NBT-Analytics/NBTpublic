classdef skurtosis < spt.feature.feature & goo.verbose
    % SKURTOSIS - Spatial kurtosis
    
    properties
       Nonlinearity = @(x) (x./norm(x)).^2;
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
        [idx, featName] = extract_feature(obj, sptObj, tSeries, raw, varargin)     
        
        % Constructor
        
        function obj = skurtosis(varargin)
            import misc.set_properties;
            
            if nargin < 1, return; end
            
            opt.Nonlinearity = @(x) (x./norm(x)).^2;
            obj = set_properties(obj, opt, varargin);
            
        end
        
    end
    
end