classdef mmappset < ...
        handle                      & ...
        goo.abstract_setget_handle  & ...
        goo.verbose_handle          & ...
        goo.abstract_named_object_handle
    % MMAPPSET - Interface for memory-mapped point sets
    
    methods (Abstract)
        
        y   = subsref(obj, s);
        
        obj = subsasgn(obj, s, b);
        
        filename        = get_datafile(obj);
        
        filename        = get_hdrfile(obj);
        
        newObj          = copy(obj, varargin);
        
        newObj          = subset(obj, varargin);
        
        obj             = concatenate(varargin);
        
        nDims           = nb_dim(obj);
        
        nPnts           = nb_pnt(obj);
        
        save(obj, filename);
        
        obj = delay_embed(obj, varargin);
        
        obj = loadobj(obj);
        
        obj = saveobj(obj);
        
        obj = move(obj, varargin);
        
        obj = sphere(obj, varargin);
        
        obj = smooth_transitions(obj, evArray, varargin);
        
        % Selection related methods
        
        obj = select(obj, varargin);
        
        obj = clear_selection(obj);
        
        obj = restore_selection(obj);
        
        obj = backup_selection(obj);
        
        % Projection related methods
        
        obj = project(obj, varargin);
        
        obj = clear_projection(obj);
        
        obj = restore_projection(obj);
        
        obj = backup_projection(obj);
        
        bool = is_temporary(obj);
        
    end
    
    
end