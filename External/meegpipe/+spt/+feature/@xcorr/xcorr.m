classdef xcorr < spt.feature.feature & goo.verbose
    % XCORR - Select components by cross-correlating them with a ref.
    
    properties
        
        RefSelector;
        AggregatingStat = @(corrVal) median(corrVal);
        
    end
    
    methods
        
        function obj = set.RefSelector(obj, value)
            import exceptions.InvalidPropValue;
            if isempty(value),
                obj.RefSelector = [];
                return;
            end
            
            if numel(value) ~= 1 || ~isa(value, 'pset.selector.selector'),
                throw(InvalidPropValue('RefSelector', ...
                    'Must be a selector object'));
            end
            
            obj.RefSelector = value;
            
        end
        
        function obj = set.AggregatingStat(obj, value)
            import exceptions.InvalidPropValue;
            
            if isempty(value),
                obj.AggregatingStat = @(corrVal) median(corrVal);
                return;
            end
            
            if ~isa(value, 'function_handle'),
                throw(InvalidPropValue('AggregatingStat', ...
                    'Must be a function_handle'));
            end
            
            testVal = value(rand(1,10));
            
            if numel(testVal) ~= 1 || ~isnumeric(testVal),
                throw(InvalidPropValue('AggregatingStat', ...
                    'Invalid function_handle'));
            end            
            
            obj.AggregatingStat = value;
            
        end
        
    end
    
    methods (Static)
        
        obj = bcg(varargin);
        
    end
    
    methods
        
        [featVal, featName] = extract_feature(obj, sptO, tSeries, raw, rep, varargin);
        
        % Constructor
        
        function obj = xcorr(varargin)
            import misc.set_properties;
            
            if nargin < 1, return; end
            
            opt.RefSelector = [];
            opt.AggregatingStat = @(corrVal) median(corrVal);
            obj = set_properties(obj, opt, varargin);
            
        end
        
    end
    
    
    
end