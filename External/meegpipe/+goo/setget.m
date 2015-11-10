classdef setget
    % SETGET - A generic set/get interface
    
    methods (Abstract)
       
        obj   = set(obj, varargin);
        value = get(obj, varargin);
        
        obj   = set_meta(obj, varargin);
        value = get_meta(obj, varargin);
        obj   = unset_meta(obj, varargin);
        props = meta_props(obj);
                
        [setNames, getNames] = fieldnames(obj);
        
        disp_body(obj);
        disp_meta(obj);
        
    end
    
    
end