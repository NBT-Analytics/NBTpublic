classdef plotter < handle
    % PLOTTER - Interface for plotter classes
    
    
    methods (Abstract)
      
        disp(obj);        
        
        obj = plot(obj, varargin);       
        
        obj = blackbg(obj, varargin); 
        
    end
    
    
    
end