classdef matrix < spt.abstract_spt
    % MATRIX - Builds a dummy BSS object based on user-defined proj/bproj
    % matrix
    
    methods
        function obj = learn_basis(obj, ~, varargin)
           % A dummy method 
        end
    end
    
    methods
        
        function obj = matrix(W, A, varargin)
            import misc.set_properties;
            if nargin < 2 || isempty(A),
                A = pinv(W);
            end
            
            obj = obj@spt.abstract_spt(varargin{:});             
            
            obj.A = A;
            obj.W = W;
            obj.ComponentSelection = 1:size(W, 1);
            obj.DimSelection = 1:size(A,1);
        end
        
    end
    
    
end