classdef method_config
    % METHOD_CONFIG - Helper class for method_configurable classes
    
    properties (SetAccess = private, GetAccess = private)
        
        MethodConfig = [];
        
    end
    
    methods
        
        obj = set_method_config(obj, varargin);
        
        value = get_method_config(obj, varargin);
        
    end
    
    
    % Constructor
    methods
        function obj = method_config(varargin)
       
            if nargin == 1 && isa(varargin{1}, 'goo.method_config'),
                % Copy constructor
                obj = varargin{1};
                return;
            end
            
            obj.MethodConfig = mjava.hash;
            
            obj = set_method_config(obj, varargin{:});
            
        end
        
    end
    
end