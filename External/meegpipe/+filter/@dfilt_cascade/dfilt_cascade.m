classdef dfilt_cascade < filter.dfilt
% DFILT_CASCADE - A cascade of two or more digital filters
%
% The difference between this class and the filter.cascade class is in the
% class of filters that can be cascaded. Class filter.cascade admits only
% abstract_dfilt objects, while class dfilt_cascade admits more generic
% dfilt objects. 
%
% See also: cascade


    properties
       Filter;        
    end
    
    % Consistency checks
    methods
        
        function obj = set.Filter(obj, value)
            import filter.cascade;
            import exceptions.*;
            
            isValid = iscell(value) && ...
                all(cellfun(@(x) isa(x, 'filter.dfilt'), value));
            if ~isValid,
                throw(InvalidPropValue('Filter', ...
                    'Must be a cell array of filter.dfilt objects'));
            end
            obj.Filter = value;
        end
    
    end
    
    % filter.dfilt interface
    methods
        
        [y, obj] = filter(obj, x, varargin);   
        
        [y, obj] = filtfilt(obj, varargin);
     
    end
  
    % Constructor
    methods
        function obj = dfilt_cascade(varargin)
            if nargin < 1, return; end
            
            obj.Filter = varargin;
        end
    end
    
    
    
    
    
end