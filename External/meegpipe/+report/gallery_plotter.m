classdef gallery_plotter < handle
    % GALLERY_PLOTTER - Interface for plotters accepted by report.plotter
   
    
    methods (Abstract)
        
       [h, groups, captions, extra, extraCap] = plot(obj, data, varargin); 
       
    end
    
end