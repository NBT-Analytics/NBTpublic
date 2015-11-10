classdef cascade < filter.abstract_dfilt
    
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
        
        function [y, obj] = filter(obj, data, varargin)
            y = data;
            for i = 1:numel(obj.Filter)
                y = filter(obj.Filter{i}, y, varargin{:});
            end
        end
        
        function [y, obj] = filtfilt(obj, data, varargin)
            y = data;
            for i = 1:numel(obj.Filter)
                y = filtfilt(obj.Filter{i}, y, varargin{:});
            end
        end
        
        function H = mdfilt(obj)
            if isempty(obj.Filter),
                H = [];
                return;
            end
            filterArray = obj.Filter;
            for i = 1:numel(filterArray)
                filterArray{i} = mdfilt(filterArray{i});
            end
            H = cascade(filterArray{:});
        end
        
    end
    
    % Constructor
    methods
        function obj = cascade(varargin)
            if nargin < 1, return; end
            
            obj.Filter = varargin;
        end
    end
    
    
    
    
    
end