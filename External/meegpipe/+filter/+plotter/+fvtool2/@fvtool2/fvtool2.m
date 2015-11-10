classdef fvtool2 < ...
        report.abstract_gallery_plotter & ...
        goo.reportable_handle
    
    %% PUBLIC INTERFACE ...................................................
    
    % report.gallery_plotter interface
    methods
        [h, groups, captions, extra, extraCap] = plot(obj, data, varargin);
    end
    
    %% report.reportable interface
    methods 
       
        function [pName, pValue, pDescr]   = report_info(obj, varargin)
           
            [pName, pValue, pDescr] = report_info(get_config(obj), ...
                varargin{:});
            
        end
       
       % What is this object for?
       function str = whatfor(obj)
           
           str = whatfor(get_config(obj));
           
       end
       
   end
    
    % Constructor
    methods
        function obj = fvtool2(varargin)
            
            obj = obj@report.abstract_gallery_plotter(varargin{:});  
            
        end
    end
    
    
end