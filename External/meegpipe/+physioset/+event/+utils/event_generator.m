classdef event_generator < handle
    
    properties (Access = private)
        
        Responder;
        
    end
    
    events
        AddEventGui;
        DelEventGui;
    end
    
    % Consistency checks
    methods
        
        function set.Responder(obj, value)
            
            if ~isa(value, 'handle'),
                throw(InvalidPropValue('Responder', ...
                    'Must be a handle object'));
            end
            
            obj.Responder = value;
            
        end
        
    end
    
    methods
        
        function trigger_event(obj, type, varargin)
            
            notify(obj, type, varargin{:});
            
        end
        
        function resp = get_responder(obj)
           
            resp = obj.Responder;
            
        end
        
        % Constructor
        function obj = event_generator(responder)
            
            if nargin < 1, return; end
            
            obj.Responder = responder;
            
        end
        
    end
    
end