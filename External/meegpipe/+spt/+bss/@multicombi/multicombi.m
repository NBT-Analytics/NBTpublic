classdef multicombi < spt.abstract_spt
    % MULTICOMBI - Multicombi algorithm for BSS
    
    properties
        AROrder =  10;
    end
    
    methods
        obj = learn_basis(obj, data, varargin);
    end
    
    methods
        
        function obj = multicombi(varargin)
            import misc.set_properties;
            import misc.split_arguments;
            
            opt.AROrder = 10;
            [thisArgs, argsParent] = split_arguments(fieldnames(opt), varargin);
            
            obj = obj@spt.abstract_spt(argsParent{:});
            
            obj = set_properties(obj, opt, thisArgs);
            
        end
        
    end
    
    
    
end