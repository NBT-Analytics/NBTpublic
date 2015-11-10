classdef setget_handle < handle
    % SETGET_HANDLE - A generic set/get interface for handle classes
    
    methods (Abstract)
       
        obj   = set(obj, varargin);
        value = get(obj, varargin);
        
        obj   = set_meta(obj, varargin);
        value = get_meta(obj, varargin);
        
        [setNames, getNames] = fieldnames(obj);        
                
        disp_body(obj);
        disp_meta(obj);        
        
    end
    
    
end