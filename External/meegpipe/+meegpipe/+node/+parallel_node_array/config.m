classdef config < meegpipe.node.abstract_config
    % CONFIG - Configuration for node parallel_node_array

    properties
        
        NodeList   = {};
        Aggregator = []; %@(varargin) sum(varargin{:});
        CopyInput  = true; % Should the input to the node be copied?
        
    end
    
    % Consistency checks (to be done)
    methods
        
        function set.CopyInput(obj, value)
           import exceptions.*;
           
           if isempty(value),
               obj.CopyInput = true;
               return;
           end
           
           if numel(value) ~= 1 || ~islogical(value),
               throw(InvalidPropValue('CopyInput', ...
                   'Must be a logical scalar'));
           end
           obj.CopyInput = value;
            
        end
       
        function set.NodeList(obj, value)
            import exceptions.*;
            
            if isempty(value),
                obj.NodeList = {};
                return;
            end
            
            if ~iscell(value),
                value = {value};
            end
            
            if ~all(cellfun(@(x) isempty(x) || ...
                    isa(x, 'meegpipe.node.node'), value)),
                throw(InvalidPropValue('NodeList', ...
                    'Must be a cell array of node objects'));
            end
        
            obj.NodeList = value;
            
        end
        
        function set.Aggregator(obj, value)
            import exceptions.InvalidPropValue;
            
            if isempty(value),
                obj.Aggregator = [];
                return;
            end
            
            if ~isa(value, 'function_handle'),
                throw(InvalidPropValue('Aggregator', ...
                    'Must be function_handle'));
            end
            
            obj.Aggregator = value;
        end
      
        
    end
   
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@meegpipe.node.abstract_config(varargin{:});            
           
        end
        
    end
    
    
    
end