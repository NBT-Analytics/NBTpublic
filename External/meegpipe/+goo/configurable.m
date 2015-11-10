classdef configurable
   % CONFIGURABLE - Interface for configurable classes
   
   
   methods (Abstract)
       val = get_config(obj, varargin);
       obj = set_config(obj, varargin);
       disp_body(obj);   
       clone(obj);
   end  
    
    
end