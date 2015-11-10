classdef config < goo.abstract_setget_handle
    % CONFIG - Configuration of class table
    %
    % * This is just a dummy class at this moment
    
    
    
    %% PUBLIC INTERFACE ...................................................
    
    properties
        Title = '';
    end
    
    % Contructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@goo.abstract_setget_handle(varargin{:});
            
        end
        
    end
    
end