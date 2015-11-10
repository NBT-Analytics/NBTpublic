classdef config < meegpipe.node.abstract_config
    % CONFIG - Configuration of erp nodes
    %
    % See: <a href="matlab:misc.md_help('meegpipe.node.erp.config')">misc.md_help(''meegpipe.node.erp.config'')</a>
 
    
    properties
        
        EventSelector  = physioset.event.class_selector('Type', 'erp')
        Offset         = [];
        Duration       = [];
        Baseline       = [];
        Filter         = [];
        TrialsFilter   = [];
        PeakLatRange   = [0.1 Inf];
        AvgWindow      = 0.05;
        MinMax         = 'max';        % ERP peak is a minimum or a maximum
        Channels       = {'.+'};       % A regex
        
    end
    
    % Consistency checks
    
    methods
        
        function obj = set.EventSelector(obj, value)
            
            import exceptions.*;
            
            if isempty(value),
                value = physioset.event.class_selector('Type', 'erp');
            end
            
            if numel(value) ~= 1 || ...
                    ~isa(value, 'physioset.event.selector'),
                throw(InvalidPropValue('EventSelector', ...
                    'Must be an event selector object'));
            end
            
            obj.EventSelector = value;
            
            
        end
        
        function obj = set.Offset(obj, value)
            
            import exceptions.*;
            
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
        
        function obj = set.Duration(obj, value)
            
            import exceptions.*;
            
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
        
        function obj = set.Baseline(obj, value)
            
            import exceptions.*;
            
            if isempty(value),
                obj.Baseline = [];
                return;
            end
            
            if numel(value) ~= 2 || ~isnumeric(value)
                throw(InvalidPropValue('Baseline', ...
                    'Must be a numeric 1x2 vector'));
            end
            
            obj.Baseline = value;
            
        end
        
        function obj = set.Filter(obj, value)
            
            import exceptions.*;
            
            if isempty(value),
                obj.Filter = [];
                return;
            end
            
            if numel(value) ~= 1 || ~isa(value, 'filter.dfilt')
                throw(InvalidPropValue('Filter', ...
                    'Must be a dfilt object'));
            end
            
            obj.Filter = value;
            
        end
        
        function obj = set.Channels(obj, value)
            
            import exceptions.*;
            
            if isempty(value),
                value = {'.+'};
            end
            
            if ischar(value),
                value = {value};
            end
            
            ME = InvalidPropValue('Channels', ...
                'Must be a cell array of strings or a regex');
            
            if iscell(value),
                if any(cellfun(@(x) ~ischar(x) & ~iscell(x), value)),
                    throw(ME);
                end
            else
                throw(ME);
            end
            
            obj.Channels = value;
            
        end
        
    end
    
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@meegpipe.node.abstract_config(varargin{:});
            
        end
        
    end
    
    
end