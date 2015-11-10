classdef amica < spt.abstract_spt
    
    properties
        NbMixtures  = 3;
        MaxIter     = 500;
        UpdateRho   = true;
        MinLL       = 1e-8;
        IterWin     = 50;
        DoNewton    = true;
    end
    
    methods
        data = learn_basis(obj, data, varargin);
    end
    
    methods
        function obj = amica(varargin)
            import misc.set_properties;
            import misc.split_arguments;
            
            opt.NbMixtures  = 3;
            opt.MaxIter     = 500;
            opt.UpdateRho   = true;
            opt.MinLL       = 1e-8;
            opt.IterWin     = 50;
            opt.DoNewton    = true;
            [thisArgs, argsParent] = split_arguments(fieldnames(opt), varargin);
            
            obj = obj@spt.abstract_spt(argsParent{:});
            
            obj = set_properties(obj, opt, thisArgs);
            
        end
    end
    
end