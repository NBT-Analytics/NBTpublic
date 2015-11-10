classdef config < meegpipe.node.abstract_config
    % CONFIG - Configuration of split nodes
    %
    % See: <a href="matlab:misc.md_help('meegpipe.node.split.config')">misc.md_help(''meegpipe.node.split.config'')</a>
    
    
    %% PUBLIC INTERFACE ...................................................
    
    properties
        
        EventSelector = ...
            physioset.event.class_selector('Class', 'split_begin');
        Duration = [];
        Offset   = [];
        SplitNamingPolicy = @(data, ev, idx) ['split' num2str(idx)];
        
    end
    
    % Consistency checks
    methods
        
        function obj = set.EventSelector(obj, value)
            
            import exceptions.*;
            if isempty(value),
                obj.EventSelector = ...
                    physioset.event.class_selector('Class', 'split_begin');
                return;
            end
            
            if numel(value) ~= 1 || ~isa(value, 'physioset.event.selector'),
                throw(InvalidPropValue('SubsetSelector', ...
                    'Must be an event selector object'));
            end
            obj.EventSelector = value;
            
        end
        
        function obj = set.Duration(obj, value)
           
            import exceptions.InvalidPropValue;
            
            if isempty(value),
                obj.Duration = [];
                return;
            end
            
            if numel(value) ~= 1 || ~isnumeric(value)
                throw(InvalidPropValue('Duration', ...
                    'Must be a numeric scalar'));
            end
            
            obj.Duration = value;
            
            
        end
        
        function obj = set.Offset(obj, value)
           
            import exceptions.InvalidPropValue;
            
            if isempty(value),
                obj.Offset = [];
                return;
            end
            
            if numel(value) ~= 1 || ~isnumeric(value)
                throw(InvalidPropValue('Offset', ...
                    'Must be a numeric scalar'));
            end
            
            obj.Offset = value;
            
            
        end
        
        function obj = set.SplitNamingPolicy(obj, value)
            
            import exceptions.InvalidPropValue;
            
            if isempty(value),
                obj.SplitNamingPolicy = ...
                    @(data, ev, idx) ['split' num2str(idx)];
                return;
            end
            
            if ~isa(value, 'function_handle'),
                throw(InvalidPropValue('SplitNamingPolicy', ...
                    'Must be a function_handle'));
            end
            
            obj.SplitNamingPolicy = value;            
            
        end
        
    end
    
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@meegpipe.node.abstract_config(varargin{:});
            
        end
        
    end
    
    
    
end