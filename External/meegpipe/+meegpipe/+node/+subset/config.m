classdef config < meegpipe.node.abstract_config
    % CONFIG - Configuration of resample nodes
    %
    % See: <a href="matlab:misc.md_help('meegpipe.node.resample.config')">misc.md_help(''meegpipe.node.resample.config'')</a>
    
  
    properties
        
        AutoDestroyMemMap = false;
        
    end
   
    
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@meegpipe.node.abstract_config(varargin{:});
            
        end
        
    end
    
    
    
end