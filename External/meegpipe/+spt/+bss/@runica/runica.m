classdef runica < spt.abstract_spt
    
    
    properties
        
        Extended = true;
        
    end
    
    % Consistency checks
    methods
        
        function obj = set.Extended(obj, value)
            
            import misc.join;
            import exceptions.*
            
            
            if numel(value) ~= 1 || ~islogical(value)
                throw(InvalidPropValue('Extended', ...
                    'Must be a logical scalar'));
            end
            
            obj.Extended = value;
            
        end
        
        
    end
    
    methods
        
        obj = learn_basis(obj, data, varargin);
        
    end
    
    
    % Constructor
    methods
        function obj = runica(varargin)
            import misc.set_properties;
            import misc.split_arguments;

            opt.Extended = true;
            [thisArgs, argsParent] = split_arguments(fieldnames(opt), varargin);
            
            obj = obj@spt.abstract_spt(argsParent{:});
            
            obj = set_properties(obj, opt, thisArgs);
          
        end
    end
    
end