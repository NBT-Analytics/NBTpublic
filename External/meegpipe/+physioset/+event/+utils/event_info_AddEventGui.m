classdef event_info_AddEventGui < event.EventData
    
   
    properties
        EventArray;
    end
    
    methods
       
        function obj = event_info_AddEventGui(evArray)
           
            obj.EventArray = evArray;
            
        end
        
    end
    
    
end