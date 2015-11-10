classdef ewasobi < spt.abstract_spt
    % EWASOBI - eWASOBI algorithm for blind source separation
    
    properties
        AROrder = 10;   
    end         
    
    % Consistency checks
    methods
        
        function obj = set.AROrder(obj, value)
            import exceptions.*;
            import misc.isinteger;            
            
            if numel(value) ~= 1 || ~isinteger(value) || value < 0,
                throw(InvalidPropValue('AROrder', ...
                    'Must be a natural scalar'));
            end
            obj.AROrder = value;            
        end
        
    end
    
    methods
        data = learn_basis(obj, data, varargin);
    end
    
    % Constructor
    methods
        function obj = ewasobi(varargin)
            import misc.set_properties;
            obj = obj@spt.abstract_spt(varargin{:});
            
            opt.AROrder = 10;            
            obj = set_properties(obj, opt, varargin{:});
        
        end
        
    end
    
    
end