classdef reportable_handle < handle
   % REPORTABLE_HANDLE - Interface for self-reporting handle classes
   %
   % 
   % See also: reportable

   methods (Abstract)
       
      [pName, pValue, pDescr]   = report_info(obj, varargin);
      
      str = whatfor(obj);
      
   end
    
    
end