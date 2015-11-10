classdef config < goo.abstract_setget_handle
    % CONFIG - Configuration for class object
    %
    % * At this moment this is a dummy class
    %
    %
    % See also: object
    
    % Description: Helper configuration class
    % Documentation: pkg_object.txt
   
  
    
    %% PUBLIC INTERFACE ...................................................
    
        
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@goo.abstract_setget_handle(varargin{:});            
           
        end
        
    end
    
end