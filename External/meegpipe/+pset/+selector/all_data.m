classdef all_data < pset.selector.abstract_selector
    
    
    
    
    properties (SetAccess = private, GetAccess = private)
        
        Negated             = false;
        
    end
    
    % pset.selector.selector interface
    methods
        
        function obj = not(obj)
            
           % Do nothing
           obj.Negated = ~obj.Negated;
            
        end
        
        function [data, emptySel, arg] = select(obj, data, remember)
            
            arg = [];
            
            if nargin < 3 || isempty(remember),
                remember = true;
            end
            
            if obj.Negated,
                 emptySel = true;
                 return;
            else
                emptySel = false;
                select(data, 1:size(data,1), 1:size(data,2), remember);
            end
          
        end
        
    end
    
    
    methods
        
        function disp(obj)
            
            import goo.disp_class_info;
            
            disp_class_info(obj);
            
            if obj.Negated,
                fprintf('%20s : yes\n', 'Negated');
            else
                fprintf('%20s : no\n', 'Negated');
            end
            
        end
        
        function obj = all_data(varargin)
            
            obj = obj@pset.selector.abstract_selector(varargin{:});
            
        end
        
    end
    
    
    
    
end