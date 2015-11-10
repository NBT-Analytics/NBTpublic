classdef selector
    % SELECTOR - Interface for event selectors
    %
    % See also: event
    
    methods (Abstract)
        
       [evArray, idx] = select(obj, evArray); 
       
       obj = not(obj);
       
    end
    
    
end