classdef spt
    % SPT - Interface for spatial transforms
    
    methods (Abstract)
        
        % Mutable abstract methods
        
        obj          = sort(obj, sortingFeature, varargin);
        
        obj          = learn(obj, data, ev, sr);
        
        obj          = match_sources(source, target, varargin);
        
        obj          = select_component(obj, idx, backup);
        
        obj          = select_dim(obj, idx, backup);
        
        obj          = select(obj, compIdx, dimIdx, backup);
        
        obj          = clear_selection(obj);
        
        obj          = restore_selection(obj);
        
        varargout    = cascade(varargin);  
        
        obj          = reorder_component(obj, idx);
  
       
        % Inmutable abstract methods
        
        W           = projmat(obj, fullMatrix);
        
        A           = bprojmat(obj, fullMatrix);
        
        [data, I]   = proj(obj, data);
        
        [data, I]   = bproj(obj, data);
        
        I           = component_selection(obj);    
        
        I           = dim_selection(obj);
        
        val         = nb_dim(obj);
        
        val         = nb_component(obj);
        
        
    end
    
    
end