classdef cca < spt.abstract_spt
    % CCA - BSS using Canonical Correlation Analysis
    
    properties (SetAccess = private, GetAccess = private)
        CorrVal = [];
    end
    
    properties
        Delay = 1;
        MaxCorr = 1;
        MinCorr = 0;
        MinCard = 0;
        MaxCard = Inf;
        TopCorrFirst = true;
    end
    
    methods
        
        obj = learn_basis(obj, X, varargin);
        
        function corrVal = get_component_correlation(obj, idx)
            
            if nargin < 2 || isempty(idx),
                idx = 1:numel(obj.CorrVal);
            end
            
            corrVal = obj.CorrVal(idx);
            
        end
        
        function obj = cca(varargin)
            import misc.set_properties;
            import misc.split_arguments;
            
            opt.Delay = 1;
            opt.MaxCorr = 1;
            opt.MinCorr = 0;
            opt.MinCard = 0;
            opt.MaxCard = Inf;
            opt.TopCorrFirst = true;
            [thisArgs, argsParent] = split_arguments(fieldnames(opt), varargin);
            
            obj = obj@spt.abstract_spt(argsParent{:});
            
            obj = set_properties(obj, opt, thisArgs);
            
        end
        
    end
    
    
    
end

