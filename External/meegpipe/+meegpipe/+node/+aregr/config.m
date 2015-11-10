classdef config < meegpipe.node.abstract_config
    % CONFIG - Configuration of aregr nodes
    %
    % See: <a href="matlab:misc.md_help('meegpipe.node.aregr.config')">misc.md_help(''meegpipe.node.aregr.config'')</a>
    
    %% PUBLIC INTERFACE ...................................................
    
    properties
        
        Filter          = filter.mlag_regr;;
        Regressor       = [];
        Measurement     = [];
        ChopSelector    = [];
        ExpandBoundary  = false;
        
    end
    
    % Consistency checks
    methods
        
        function obj = set.Filter(obj, value)
            
            import exceptions.*;
            
            if isempty(value),
                obj.Filter = meegpipe.node.aregr.globals.get.Filter;
                return;
            end
            
            if numel(value) ~= 1 || (~isa(value, 'filter.rfilt') && ...
                    ~isa(value, 'function_handle')),
                throw(InvalidPropValue('Filter', ...
                    'Must be a filter.rfilt object or a function_handle'));
            end
            
            obj.Filter = value;
            
            
        end
        
        function obj = set.Regressor(obj, value)
            
            import exceptions.*;
            
            if isempty(value),
                value = [];
                return;
            end
            
            if ~isa(value, 'pset.selector.selector'),
                throw(InvalidPropValue('Regressor', ...
                    'Must be a selector object'));
            end
            
            obj.Regressor = value;
            
        end
        
        function obj = set.Measurement(obj, value)
            
            import exceptions.*;
            
            if isempty(value),
                value = [];
                return;
            end
            
            if ~isa(value, 'pset.selector.selector'),
                throw(InvalidPropValue('Measurement', ...
                    'Must be a selector object'));
            end
            
            obj.Measurement = value;
            
        end
        
    end
    
    
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@meegpipe.node.abstract_config(varargin{:});
            
        end
        
    end
    
    
    
end