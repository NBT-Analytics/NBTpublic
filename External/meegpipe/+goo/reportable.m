classdef reportable 
   % REPORTABLE - Interface for reportable classes
   %
   % * A minimalistic interface for self-reporting classes
   % 
   % See also: reportable_handle 
   
   
   methods (Abstract)
       
       [pName, pValue, pDescr]   = report_info(~, varargin)
       
       % What is this object for?
       str                       = whatfor(obj);
       
   end
    
    
end