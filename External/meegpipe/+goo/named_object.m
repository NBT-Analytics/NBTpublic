classdef named_object
    
    methods (Abstract)
       
        name = get_name(obj);
        
        name = get_full_name(obj);
        
        obj  = set_name(obj, name);
        
    end
    
    
end