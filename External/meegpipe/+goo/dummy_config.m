classdef dummy_config  < ...
        goo.abstract_setget_handle & ...
        goo.reportable_handle
    
    methods
       
        function obj = dummy_config(varargin)
            
            obj = obj@goo.abstract_setget_handle(varargin{:});
            
        end
        
    end
    
end