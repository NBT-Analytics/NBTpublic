classdef topography < ...
        report.abstract_gallery_plotter & ...
        goo.verbose_handle
    
  
    % Public interface ....................................................
    methods
        % report.plotter interface
        [h, groups, captions, extra, extraCap, config] = plot(obj, ...
            sensors, data, dataName);
     
    end
    
    % Constructor
    methods 
        
        function obj = topography(varargin)
           
           obj = obj@report.abstract_gallery_plotter(varargin{:});
           
        end
        
    end
    
    
end