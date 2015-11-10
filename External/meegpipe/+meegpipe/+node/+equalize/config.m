classdef config < meegpipe.node.abstract_config
    % CONFIG - Configuration for node equalize
    %   
    %
    % See also: equalize
  
    properties       
        
        RefSelector = [];
        
    end
    
  
    % Constructor
    methods
        
        function obj = config(varargin)
           
            obj = obj@meegpipe.node.abstract_config(varargin{:});  
            
        end
        
    end
    
    
    
end