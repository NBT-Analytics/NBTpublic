classdef abstract_selector < ...
        physioset.event.selector & ...
        goo.abstract_named_object & ...
        goo.abstract_setget
    
    
    
    
    methods
       
        function obj = abstract_selector(varargin)
            
            obj = obj@goo.abstract_named_object(varargin{:});  
            
        end
        
    end
    
    
end