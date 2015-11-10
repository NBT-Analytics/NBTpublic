classdef config < meegpipe.node.abstract_config
    % CONFIG - Configuration for channel rejection criterion bad_epochs
    %
    % See: <a href="matlab:misc.md_help('meegpipe.node.bad_channels.criterion.bad_epochs.config')">misc.md_help(''meegpipe.node.bad_channels.criterion.bad_epochs.config'')</a>
    
   
    properties
        
        BadEpochsCriterion;
        EventSelector;
        Max = 0.75;
        
    end
    
    % Consistency checks
    methods
       
       
        function obj = set.BadEpochsCriterion(obj, value)
           
            import exceptions.*;
            import misc.isnatural;
            
            if isempty(value),
                obj.BadEpochsCriterion = [];
                return;
            end
            
            if numel(value) > 1 || ~isa(value, ...
                    'meegpipe.node.bad_epochs.criterion.criterion'),
                throw(InvalidPropValue('BadEpochsCriterion', ...
                    'Must be a meegpipe.node.bad_epochs.criterion.criterion'));
            end
            
            obj.BadEpochsCriterion = value;
            
        end
        
        function obj = set.EventSelector(obj, value)
            
            import exceptions.*;
            
            if isempty(value),
                obj.EventSelector = [];
                return;
            end
            
            if numel(value) > 1 || ...
                    ~isa(value, 'physioset.event.selector')
                throw(InvalidPropValue('EventSelector', ...
                    'Must be a pset.event.selector'));
            end
            
            obj.EventSelector = value;
            
        end
        
        function obj = set.Max(obj, value)
           
            import exceptions.*;
            
            if isempty(value),
                % Default
                obj.Max = 0.75;
                return;
            end
            
            if numel(value) ~= 1 || ...
                    (~isnumeric(value) && ~isa(value, 'function_handle')),
                throw(InvalidPropValue('Max', ...
                    'Must be a scalar or a function_handle'));
            end
            
            obj.Max = value;
            
        end
        
    end
    
    
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@meegpipe.node.abstract_config(varargin{:});            
            
        end
        
    end
    
    
    
end