classdef abstract_gallery_plotter < ...
        report.gallery_plotter              & ...
        goo.abstract_configurable_handle    & ...
        goo.reportable_handle               & ...
        goo.verbose_handle                  & ...
        goo.abstract_named_object_handle    & ...
        goo.hashable_handle
    
  
   
    methods
        
        % goo.hashable_handle interface
        function str = get_hash_code(~)
           % This has to be a constant. Otherwise, changing the plotter
           % object in a node configuration will look like the part of the
           % node config relevant for reproducibility has changed and it
           % hasn't.
           str = ''; 
        end
        
         % goo.reportable interface
        function str = whatfor(~)            
            str = '';            
        end
        
        % Children will probably want to redefine method report_info
        function [pName, pValue, pDescr]   = report_info(obj, varargin)
            
            [pName, pValue, pDescr]   = report_info(get_config(obj));
            
        end
        
    end
    
   
    % abstract constructor
    methods
        
        function obj = abstract_gallery_plotter(varargin)
            
            obj = obj@goo.abstract_configurable_handle(varargin{:});
           
            
        end
        
    end
    
    
end