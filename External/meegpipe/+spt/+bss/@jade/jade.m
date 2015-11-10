classdef jade < spt.abstract_spt
    % JADE - Jade algorithm for blind source separation
    
    methods
        obj = learn_basis(obj, data, varargin);
    end
    
    methods
        
        function obj = jade(varargin)
            import misc.set_properties;
            obj = obj@spt.abstract_spt(varargin{:}); 
        end
        
    end
    
    
end