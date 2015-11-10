classdef config < goo.abstract_setget_handle & ...
        goo.reportable_handle
    
   
    
    %% PUBLIC INTERFACE ...................................................
    
    properties
        
        BlackBgPlots = filter.plotter.fvtool2.globals.get.BlackBgPlots;
        SVG          = filter.plotter.fvtool2.globals.get.SVG;
        PrintDrivers = filter.plotter.fvtool2.globals.get.PrintDrivers;    
        Folder       = '';    
        Visible      = filter.plotter.fvtool2.globals.get.Visible;
        
    end
    
    % Consistency checks
    methods
        
        function obj = set.BlackBgPlots(obj, value)
            
            import eegpipe.exceptions.*;
            if isempty(value), value = true; end
            
            if ~islogical(value) || numel(value) ~= 1,
                throw(InvalidPropValue('BlackBgPlots', ...
                    'Must be a logical scalar'));
            end
            obj.BlackBgPlots = value;
        end
        
        function obj = set.SVG(obj, value)
            
            import eegpipe.exceptions.*;
            if isempty(value), value = true; end
            
            if ~islogical(value) || numel(value) ~= 1,
                throw(InvalidPropValue('SVG', ...
                    'Must be a logical scalar'));
            end
            obj.SVG = value;
        end
        
        function obj = set.PrintDrivers(obj, value)
            
            import eegpipe.exceptions.*;
            if ischar(value),
                value = {value};
            end
            
            if ~all(cellfun(@(x) ischar(x) && ~isempty(x), value)),
                throw(InvalidPropValue('PrintDrivers', ...
                    'Must be a cell array of strings'));
            end
            
            obj.PrintDrivers = value;
            
        end        
        
    end
    
    % report.reportable_handle interface
    methods
       
      [pName, pValue, pDescr]   = report_info(obj, varargin);
      
      function str = whatfor(~)
         
          str = ['Class __fvtool2__ can be used to plot the amplitude '  ...
              'and phase characteristics of filter.dfilt objects'];
          
      end
      
   end
    
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@goo.abstract_setget_handle(varargin{:});
            
        end
        
    end
    
    
    
end