classdef config < meegpipe.node.abstract_config
    % CONFIG - Configuration for node center
    %
    % This is a dummy class
    %
    % See also: center
    
    
    properties
        
        RerefMatrix = @(d) eye(size(d,1));
        
    end
    
    
    
    methods
        
        function obj = set.RerefMatrix(obj, value)
            import exceptions.InvalidPropValue;
            
            if isempty(value),
                obj.RerefMatrix = @(d) eye(size(d,1));
                return;
            end
            
            if ~isnumeric(value) && ~isa(value, 'function_handle')
                throw(InvalidPropValue('RerefMatrix', ...
                    'Must be a matrix or a function_handle'));
            end
            
            obj.RerefMatrix = value;
            
        end
        
    end
    
    
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@meegpipe.node.abstract_config(varargin{:});
            
        end
        
    end
    
    
    
end