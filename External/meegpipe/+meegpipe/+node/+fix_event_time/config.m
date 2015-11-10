classdef config < meegpipe.node.abstract_config
    % CONFIG - Configuration for node fix_event_time
    %
    %
    % See also: fix_event_time
    
    %% PUBLIC INTERFACE ...................................................
    
    properties
        
        Offset        = 0;
        Duration      = [];
        MaxShift      = [];    % In samples
        EventSelector = [];
        
    end
    
    % Consistency checks to be done
    methods
        
        % Global consistency check
        function check(obj)
            import exceptions.Inconsistent;
            
            if isempty(obj.EventSelector),
                % Node does nothing so no worries
                return;
            end
            
            if isempty(obj.MaxShift),
                throw(Inconsistent(...
                    'The MaxShift must be specified'));
            end
            
        end
        
        function obj = set.Offset(obj, value)
            import exceptions.InvalidPropValue;
            import misc.isinteger;
            import goo.from_constructor;
            
            if isempty(value),
                obj.Offset = [];
                return;
            end
            
            if numel(value) ~=1 || ~isinteger(value),
                throw(InvalidPropValue('Offset', ...
                    'Must be an integer scalar'));
            end
            obj.Offset = value;
            
            if ~from_constructor(obj),
                check(obj);
            end
            
        end
        
        function obj = set.Duration(obj, value)
            import exceptions.InvalidPropValue;
            import misc.isnatural;
            import goo.from_constructor;
            
            if isempty(value),
                obj.Duration = [];
                return;
            end
            
            if numel(value) ~=1 || ~isnatural(value),
                throw(InvalidPropValue('Duration', ...
                    'Must be an natural scalar'));
            end
            obj.Duration = value;
            
            if ~from_constructor(obj),
                check(obj);
            end
            
        end
        
        function obj = set.MaxShift(obj, value)
            import exceptions.InvalidPropValue;
            import misc.isnatural;
            import goo.from_constructor;
            
            if isempty(value),
                obj.MaxShift = [];
                return;
            end
            
            if numel(value) ~=1 || ~isnatural(value),
                throw(InvalidPropValue('MaxShift', ...
                    'Must be an natural scalar'));
            end
            obj.MaxShift = value;
            
            if ~from_constructor(obj),
                check(obj);
            end
            
        end
        
        function obj = set.EventSelector(obj, value)
            import exceptions.InvalidPropValue;
            import misc.isnatural;
            import goo.from_constructor;
            
            if isempty(value),
                obj.EventSelector = [];
                return;
            end
            
            if numel(value) ~=1 || ~isa(value, 'physioset.event.selector'),
                throw(InvalidPropValue('EventSelector', ...
                    'Must be a physioset.event.selector object'));
            end
            obj.EventSelector = value;
            
            if ~from_constructor(obj),
                check(obj);
            end
            
        end
        
    end
    
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@meegpipe.node.abstract_config(varargin{:});
            
            if nargin < 1, return; end
            
            check(obj);
            
        end
        
    end
    
    
    
end