classdef config < meegpipe.node.abstract_config
    % CONFIG - Configuration of bad_channels nodes
    %
    % See: <a href="matlab:misc.md_help('meegpipe.node.bad_channels.config')">misc.md_help(''meegpipe.node.bad_channels.config'')</a>
 
    properties
        
        Criterion = meegpipe.node.bad_channels.criterion.var.var;
    end
    
    % Consistency checks
    methods
       
        function obj = set.Criterion(obj, value)
            
            import exceptions.*;

            if isempty(value),
                % Set to default
                value = meegpipe.node.bad_channels.criterion.var.var;
            end
            
            if ~isa(value, 'meegpipe.node.bad_channels.criterion.criterion'),
                throw(InvalidPropValue('Criterion', ...
                    'Must be a criterion object'));
            end
            
            obj.Criterion = value;
            
        end    
        
    end
    
    
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@meegpipe.node.abstract_config(varargin{:});
                        
        end
        
    end
    
    
    
end