classdef config < goo.abstract_setget_handle
    % CONFIG - Configuration for class generic
    %
    % * At this moment this is a dummy class
    %
    %
    % See also: generic
    

    %% PUBLIC INTERFACE ...................................................
    
        
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@goo.abstract_setget_handle(varargin{:});            
           
        end
        
    end
    
end