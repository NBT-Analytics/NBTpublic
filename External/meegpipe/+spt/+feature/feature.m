classdef feature < goo.abstract_named_object & goo.hashable & goo.printable
    
    methods (Abstract)
        
        [feature, featName] = extract_feature(obj, sptObj, sptAct, ...
            data, rep, varargin);
        
    end
  
    
end