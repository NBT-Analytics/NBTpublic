classdef config < meegpipe.node.abstract_config
    % CONFIG - Configuration for bad channels rejection criterion var
    %
    % See: <a href="matlab:misc.md_help('meegpipe.node.bad_channels.criterion.var.config')">misc.md_help(''meegpipe.node.bad_channels.criterion.var.config'')</a>
    
    
    properties
        DataSelector = [];
    end
    
    % Consistency checks
    methods
        
        function obj = set.DataSelector(obj, value)
            
            import exceptions.InvalidPropValue;
           
            if isempty(value),
                obj.DataSelector = [];
                return;
            end
            if ~isa(value, 'pset.selector.selector'),
                throw(InvalidPropValue('DataSelector', ...
                    'Must be a pset.selector.selector object'));
            end
           obj.DataSelector = value;            
        end
      
        
    end
    
    
    % Constructor
    methods
        
        function obj = config(varargin)
            obj = obj@meegpipe.node.abstract_config(varargin{:});              
        end
        
    end
    
    
    
end