classdef efica < spt.abstract_spt
    % EFICA - EFICA algorithm for Blind Source Separation
    
    methods
        data = learn_basis(obj, data, varargin);
    end
    
    methods
        function obj = efica(varargin)
            obj = obj@spt.abstract_spt(varargin{:});
            
            if isempty(get_name(obj)),
                obj = set_name(obj, 'efica');
            end
        end
        
    end    
    
end