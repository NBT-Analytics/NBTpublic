classdef config < meegpipe.node.abstract_config
    % CONFIG - Configuration for pipeline class
    %
    % 
    %
    % See also: pipeline
 
    properties
        NodeList;     
    end
    
    % Consistency checks
    methods
        
        function obj = set.NodeList(obj, value)
            
            import meegpipe.node.pipeline.config;
            import exceptions.*;            
            
            if ~isempty(value) && ~iscell(value),
                value = {value};
            elseif isempty(value),
                obj.NodeList = [];
                return;
            end
            
            % Remove empty nodes
            isEmpty = cellfun(@(x) isempty(x), value);
            value = value(~isEmpty);
            
            if ~config.check_node_specs(value),
                  throw(InvalidPropValue('NodeList', ...
                    ['Must be a cell array of node objects and/or cell '...
                    'arrays of node objects']));
            end
            
            obj.NodeList = config.no_oge_specs(value);
            
        end
        
    end
       
    %%% Helper methods (for set.Node)
    methods (Static, Access = private)
        
        bool = check_node_specs(specs);
        
        specs = no_oge_specs(specs);
        
    end
    
    
 
   
    methods
        
        
         % Constructor
        function obj = config(varargin)
            
            i = 0;
            while (i<nargin && isa(varargin{i+1}, 'meegpipe.node.node')),
                i = i + 1;
            end
            
            obj = obj@meegpipe.node.abstract_config(varargin{i+1:end});
            
            if isempty(obj.NodeList),
                obj.NodeList = varargin(1:i);
            end
            
            
        end
        
    end
    
    
    
end