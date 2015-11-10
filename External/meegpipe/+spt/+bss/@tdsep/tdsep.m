classdef tdsep < spt.abstract_spt
    % TDSEP - TDSEP algorithm for blind source separation
    
    
    properties        
        Lag = 1;
    end
    
    methods
        obj = learn_basis(obj, data, ev, varargin);
    end
    
    
    % Constructor
    methods
        
        function obj = tdsep(varargin)
            import misc.set_properties;
            import misc.split_arguments;
            
            opt.Lag = 1;
            [thisArgs, argsParent] = split_arguments(fieldnames(opt), varargin);
            
            obj = obj@spt.abstract_spt(argsParent{:});            
            
            obj = set_properties(obj, opt, thisArgs{:});
         
        end
        
    end
    
    
end