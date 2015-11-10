classdef good_samples < pset.selector.abstract_selector
    % GOOD_SAMPLES - Selects good data samples
    %
    %
    % See also: good_data
    
    %% IMPLEMENTATION
    
    properties (SetAccess = private, GetAccess = private)
        
        Negated             = false;
        
    end
    
    
    %% PUBLIC INTERFACE ....................................................
    
    % pset.selector.selector interface
    methods
        
        function obj = not(obj)
            
            obj.Negated = true;
            
        end
        
        function [data, emptySel, arg] = select(obj, data, remember)
            
            arg = [];
            
            if nargin < 3 || isempty(remember),
                remember = true;
            end
            
            if obj.Negated,
                selection = is_bad_sample(data);
            else
                selection = ~is_bad_sample(data);
            end
            
            if any(selection),
                emptySel = false;
                select(data, 1:size(data,1), selection, remember);
            else
                emptySel = true;
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
        
        function obj = good_samples(varargin)
            
            obj = obj@pset.selector.abstract_selector(varargin{:});
            
        end
        
    end
    
    
    
end