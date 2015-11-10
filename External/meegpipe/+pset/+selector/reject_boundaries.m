classdef reject_boundaries < pset.selector.abstract_selector
    % reject_boundary - Select all data except data near boundaries
    %
    % See also: selector
    
    properties (SetAccess = private, GetAccess = private)
        Negated = false;
    end
    
    properties
        StartMargin = 0; % Absolute number in samples or function_handle
        EndMargin   = 0; % Absolute number in samples or function_handle
    end
    
    % Consistency checks
    methods
        function obj = set.StartMargin(obj, value)
            import exceptions.InvalidPropValue;
            import misc.isinteger;
            
            if numel(value) ~= 1 || ...
                    (~isinteger(value) && ~isa(value, 'function_handle')),
                throw(InvalidPropValue('StartMargin', ...
                    ['Must be a natural scalar (# samples) or a ' ...
                    'function_handle']))
            end
            
            obj.StartMargin = value;
        end
        
        function obj = set.EndMargin(obj, value)
            import exceptions.InvalidPropValue;
            import misc.isinteger;
            
            if numel(value) ~= 1 || ...
                    (~isinteger(value) && ~isa(value, 'function_handle')),
                throw(InvalidPropValue('EndMargin', ...
                    ['Must be a natural scalar (# samples) or a ' ...
                    'function_handle']))
            end
            
            obj.EndMargin = value;
        end
        
    end
    
    methods
        
        % pset.selector.selector interface
        
        function obj = not(obj)
            obj.Negated = ~obj.Negated;
        end
        
        function [data, emptySel, arg] = select(obj, data, remember)
            
            arg = [];
            
            if nargin < 3 || isempty(remember), remember = true; end
            
            selected = true(1, size(data,2));
            
            if isa(obj.StartMargin, 'function_handle'),
                first = obj.StartMargin(data);
            else
                first = obj.StartMargin;
            end
            
            if isa(obj.EndMargin, 'function_handle'),
                last = size(data,2) - obj.EndMargin(data) + 1;
            else
                last = size(data,2) - obj.EndMargin + 1;
            end
            
            selected(1:min(first, size(data,2))) = false;
            selected(max(1, last):end) = false;
            
            if obj.Negated,
                selected = ~selected;
            end
            
            if ~any(selected),
                emptySel = true;
                return;
            else
                emptySel = false;
            end
            
            select(data, 1:size(data,1), selected, remember);
            
        end
        
        % Public methods declared and defined here
        
        function disp(obj)
            
            import goo.disp_class_info;
            import mperl.join;
            import goo.disp_body;
            
            disp_class_info(obj);
            
            disp_body(obj);
            
            if obj.Negated,
                fprintf('%20s : yes\n', 'Negated');
            else
                fprintf('%20s : no\n', 'Negated');
            end
            
        end
        
        % Constructor
        
        function obj = reject_boundaries(varargin)
            import misc.process_arguments;
            
            obj = obj@pset.selector.abstract_selector(varargin{:});  
            
            if nargin < 1, return; end
            
            opt.StartMargin = 0;
            opt.EndMargin   = 0;
            
            [~, opt] = process_arguments(opt, varargin, [], true);
            
            obj.StartMargin = opt.StartMargin;
            obj.EndMargin   = opt.EndMargin;
            
        end
        
        
    end
end
