classdef function_handle < ...
        filter.dfilt             & ...
        goo.verbose              & ...
        goo.abstract_setget      & ...
        goo.abstract_named_object
    % function_handle - Filter data using function_handle operator
    %
    %
    %
    % See also: filter
    
    properties
        
        Operator = [];
        Dim      = 2;
        
    end
    
    % consistency checks
    methods
        
        function obj = set.Operator(obj, value)
            
            import exceptions.InvalidPropValue;
            
            if isempty(value),
                obj.Operator = [];
                return;
            end
            
            if numel(value) ~= 1 || ~isa(value, 'function_handle'),
                throw(InvalidPropValue('Operator', ...
                    'Must be a function_handle'));
            end
            
            obj.Operator = value;
            
        end
        
        function obj = set.Dim(obj, value)
            
            import exceptions.InvalidPropValue;
            
            if isnumeric(value) && ismember(value, [1 2])
                if value == 2,
                    value = 'rows';
                else
                    value = 'cols';
                end
            end
            
            if isempty(value),
                obj.Dim = 'rows';
                return;
            end
            
            if ~ischar(value) || ~ismember(value, {'rows', 'cols'}),
                throw(InvalidPropValue('Dim', ...
                   'Either ''rows'' or ''cols'''));
            end
            obj.Dim = value;
            
        end
        
    end
    
    % filter.dfilt interface
    methods
        
        [y, obj] = filter(obj, x, d, varargin);
        
        function y = filtfilt(obj, x, varargin)
            
            y = filter(obj, x, varargin{:});
            
        end
    end
    
    
    % Constructor
    methods
        
        function obj = function_handle(varargin)
            
            import misc.process_arguments;
            
            opt.Name     = 'function_handle';
            opt.Verbose  = true;
            opt.Operator = [];
            opt.Dim      = 2;
            
            [~, opt] = process_arguments(opt, varargin);
            
            obj = set_name(obj, opt.Name);
            obj = set_verbose(obj, opt.Verbose);
            
            obj.Operator = opt.Operator;
            obj.Dim      = opt.Dim;
            
        end
        
        
    end
    
    
end