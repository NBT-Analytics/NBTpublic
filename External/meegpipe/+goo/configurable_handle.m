classdef configurable_handle < handle
   % CONFIGURABLE_HANDLE - Interface for configurable (handle) classes
   
   
   methods (Abstract)
       val = get_config(obj, varargin);
       obj = set_config(obj, varargin);
       disp_body(obj);   
   end
    
    
    
    
    
end