classdef config < meegpipe.node.abstract_config
    % CONFIG - Configuration for node operator
    %   
    %
    % See also: operator
  
    properties       
        
        Operator = @(x) x; % Identity operator
        
    end
    
  
    % Constructor
    methods
        
        function obj = config(varargin)
           
            obj = obj@meegpipe.node.abstract_config(varargin{:});  
            
        end
        
    end
    
    
    
end