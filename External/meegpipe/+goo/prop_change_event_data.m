classdef prop_change_event_data < event.EventData
   
    properties
        Property;
        OldValue;
        NewValue;
    end
    
    methods
        
        function data = prop_change_event_data(prop, oldValue, newValue)
           data.Property = prop;
           data.OldValue = oldValue;
           data.NewValue = newValue;
        end
        
    end
    
end