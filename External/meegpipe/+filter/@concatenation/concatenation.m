classdef concatenation < ...
        filter.dfilt             & ...
        goo.verbose              & ...
        goo.abstract_setget      & ...
        goo.abstract_named_object
    
    
    properties
        Filter;
    end
    
    % Consistency checks
    methods
        
        function obj = set.Filter(obj, value)
            import exceptions.*;
            
            isValid = iscell(value) && ...
                all(cellfun(@(x) isa(x, 'filter.dfilt'), value));
            if ~isValid,
                throw(InvalidPropValue('Filter', ...
                    'Must be a cell array of filter.dfilt objects'));
            end
            obj.Filter = value;
            
            name = get_name(value{1});
            if isempty(name), name = 'noname'; end
            for i = 2:numel(value)
                fName = get_name(value{i});
                if isempty(fName), fName = 'noname'; end
                name = [name '-' fName]; %#ok<AGROW>
            end
            obj = set_name(obj, name);
            
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

    end
    
    
    % Constructor
    methods
        function obj = concatenation(varargin)
            if nargin < 1, return; end
            
            obj = set_name(obj, 'concatenation');
            obj.Filter = varargin;
           
        end
    end
    
    
    
    
    
end