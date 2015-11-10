classdef config < meegpipe.node.abstract_config
    % CONFIG - Configuration for node nbt_dfa
    %
    %
    % See also: meegpipe.node.nbt_dfa.nbt_dfa
    
    
    properties
        FreqRange    = [8 13]; 
        FilterOrder;
        NbLogBins    = 10;
        FitInterval  = @(data) [5 0.1*(size(data,2)/data.SamplingRate)];
        CalcInterval = @(data) [0.1 0.1*(size(data,2)/data.SamplingRate)];
    end
    
    methods
        
        % Global consistency check
        function check(~)
            import exceptions.Inconsistent;
            
            % Check that the various property values are consistent with
            % each other. If not, throw an exception.
            
        end
        
        function obj = set.FreqRange(obj, value)
            import exceptions.InvalidPropValue;
            import goo.from_constructor;
            
            if isempty(value),
                obj.FreqRange = [8 13];
                return;
            end
            if ~isnumeric(value) || numel(value) ~= 2 || any(value < 0) || ...
                    value(2) < value(1),
                throw(InvalidPropValue('FreqRange', ...
                    'Must be a 1x2 positive vector of frequency edges'));
            end
            obj.FreqRange = value;
            if ~from_constructor(obj),
                check(obj);
            end
        end
        
        function obj = set.FilterOrder(obj, value)
            import exceptions.InvalidPropValue;
            import goo.from_constructor;
            
            if isempty(value),
                obj.FilterOrder = [];
                return;
            end
            if ~isnumeric(value) || numel(value) ~= 1 || value < 0,
                throw(InvalidPropValue('FilterOrder', ...
                    'Must be a positive scalar'));
            end
            obj.FilterOrder = value;
            if ~from_constructor(obj),
                check(obj);
            end
        end
        
        function obj = set.NbLogBins(obj, value)
            import exceptions.InvalidPropValue;
            import goo.from_constructor;
            import misc.isnatural;
            
            if isempty(value),
                obj.NbLogBins = 10;
                return;
            end
            if ~isnatural(value) || numel(value) ~= 1 || any(value < 0)
                throw(InvalidPropValue('NbLogBins', ...
                    'Must be a natural scalar'));
            end
            obj.NbLogBins = value;
            if ~from_constructor(obj),
                check(obj);
            end
        end
        
        function obj = set.FitInterval(obj, value)
            import exceptions.InvalidPropValue;
            import goo.from_constructor;
            
            if isempty(value),
                obj.FitInterval = @(data) [5 0.1*(size(data,2)/data.SamplingRate)];
                return;
            end
            if ~isa(value, 'function_handle') && ...
                    (~isnumeric(value) || numel(value) ~= 1 || value < 0),
                throw(InvalidPropValue('FitInterval', ...
                    'Muste be a 1x2 positive vector'));
            end
            obj.FitInterval = value;
            if ~from_constructor(obj),
                check(obj);
            end
        end
        
        function obj = set.CalcInterval(obj, value)
            import exceptions.InvalidPropValue;
            import goo.from_constructor;
            
            if isempty(value),
                obj.CalcInterval = @(data) [0.1 0.1*(size(data,2)/data.SamplingRate)];
                return;
            end
            if ~isa(value, 'function_handle') && ...
                    (~isnumeric(value) || numel(value) ~= 1 || value < 0)
                throw(InvalidPropValue('CalcInterval', ...
                    'Must be a 1x2 positive vector'));
            end
            obj.CalcInterval = value;
            if ~from_constructor(obj),
                check(obj);
            end
        end
        
        function obj = set_relative_defaults(obj)
            if isempty(obj.FilterOrder),
                obj.FilterOrder = 1/obj.FreqRange(1);
            end 
        end
        
        % Constructor
        function obj = config(varargin)
            
            obj = obj@meegpipe.node.abstract_config(varargin{:});
            
            if nargin < 1, return; end
            
            obj = set_relative_defaults(obj);
            
            check(obj);
            
        end
        
    end
    
    
    
end