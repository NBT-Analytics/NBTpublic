classdef event_info_DelEventGui < event.EventData
    
   
    properties
        DeleteFlag;
    end
    
    methods
       
        function obj = event_info_DelEventGui(delFlag)
           
            obj.DeleteFlag = delFlag;
            
        end
        
    end
    
    
end