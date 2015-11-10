classdef good_data < pset.selector.abstract_selector
    % GOOD_DATA - Selects only good channels and samples from physioset
    %
    % ## Usage synopsis:
    %
    % import pset.*;
    %
    % % Create sample physioset
    % X = randn(10,1000);
    % data = import(pset.import.matrix, X);
    %
    % % Mark some bad samples and bad channels
    % set_bad_channel(data, 4:5);
    % set_bad_sample(data, 100:500);
    %
    % % Construct a selector object
    % mySelector = selector.good_data;
    %
    % % Select good data from out sample dataset
    % select(mySelector, data)
    %
    % % Must be OK
    % import test.simple.ok;
    % X = X(4:5, 501:end);
    % ok(size(data,1) == 2 && size(data,2) == 500 && ...
    %   max(abs(data(:) - X(:)))<1e-3);
    %
    % See also: selector
    
     
    properties (SetAccess = private, GetAccess = private)
        
        Negated             = false;
        
    end
    
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
                selRows = is_bad_channel(data);
                selCols = is_bad_sample(data);
            else
                selRows = ~is_bad_channel(data);
                selCols = ~is_bad_sample(data);
            end
            
            if any(selRows) || any(selCols),
                emptySel = false;
                select(data, selRows, selCols, remember);
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
        
        function obj = good_data(varargin)
            
            obj = obj@pset.selector.abstract_selector(varargin{:});
            
        end
        
    end
    
    
    
    
end