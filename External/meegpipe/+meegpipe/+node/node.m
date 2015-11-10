classdef node < handle
    % NODE - Data processing node interface
    %
    %
    % See also: abstract_node, meegpipe.node

    % To be implemented by abstract_node
    
    methods (Abstract)
        
        % Nodes may be trained using training input
        myNode = train(myNode, varargin);
        
        % Accessors
        
        disp(obj);
        
        % A name that contains only word characters
        name                 = get_name(obj);
        
        % The actual name of the node (may contain any character)
        name                 = get_full_name(obj)        
       
        oge                  = get_oge(obj);
        
        dataSel              = get_data_selector(obj);
        
        save                 = get_save(obj);
        
        status               = get_report(obj);         
              
        cfg                  = get_config(obj, prop);

        fileName             = get_output_filename(obj, data);
        
        fileName             = get_ini_filename(obj);
     
        dirName              = get_dir(obj);
      
        parent               = get_parent(obj);

        [dataOut, varargout] = run(obj, dataIn, varargin);        
        
        % Modifiers
        
        obj                  = set_name(obj, name);
        
        obj                  = set_oge(obj, oge);
        
        obj                  = set_data_selector(obj, dataSel)
        
        obj                  = set_save(obj, save); 
        
        obj                  = set_config(obj, varargin);
        
        % Data conversion
        
        % The output struct should not contain references to the original
        % object (e.g. through a reference to a parent node, which itself
        % refers to the child). Otherwise, getting hash codes from node
        % objects (which often involves recursive conversion to structs and
        % other built-in types) might lead to infinite recursions.
        str         = struct(obj);
        
        % Get root directory of report
        dirName     = get_full_dir(obj, data);
       
    end
    
   
end