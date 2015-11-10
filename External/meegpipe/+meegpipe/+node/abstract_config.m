classdef abstract_config < ...
        goo.abstract_setget_handle       
    
  
    methods
        function obj = abstract_config(varargin)
            
            obj = obj@goo.abstract_setget_handle(varargin{:});
            
        end
    end
    
end