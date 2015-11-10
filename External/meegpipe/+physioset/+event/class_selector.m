classdef class_selector < physioset.event.abstract_selector
    % CLASS_SELECTOR - Selects events of standard class(es)
    %
    %
    %
    %
    % See also: event, physioset, selector, physioset.event.std
    
    
    properties
        
        Class  = {};
        Type   = {};
        Negated     = false;
        
    end
    
    methods
        
        function obj = set.Class(obj, value)
            
            import exceptions.*
            
            if ~iscell(value), value = {value}; end
            
            isEvent = cellfun(@(x) isa(x, 'physioset.event.event'), value);
            
            if any(isEvent),
                regex = '^.*?([^\.])+$';
                value(isEvent) = cellfun(@(x) regexprep(class(x), ...
                    regex, '$1'), value(isEvent), 'UniformOutput', false);
            end
            
            fullClassName = cellfun(@(x) ['physioset.event.std.' x], value, ...
                'UniformOutput', false);
            
            if ~all(cellfun(@(x) exist(x, 'class'), fullClassName)),
                
                throw(InvalidPropValue('Class', ...
                    'Must be a string/cell array of valid event name(s)'));
                
            end
            
            obj.Class = value;
            
        end
        
        function obj = set.Type(obj, value)
            
            import exceptions.*;
            import misc.join;
            
            
            if ~iscell(value), value = {value}; end
            
            isString = cellfun(@(x) misc.isstring(x), value);
            
            if ~all(isString),
                throw(InvalidPropValue('Type', ...
                    'Must be a cell array of strings'));
            end
            
            obj.Type = value;
            
               
            if isempty(obj.Name),
               
                % Name is based on the types of selected events
                name = join('_', value);
                obj = set_name(obj, name);                
                
            end
            
            
        end
        
        function obj = set.Negated(obj, value)
            import exceptions.*;
            
            if numel(value) ~= 1 || ~islogical(value),
                throw(InvalidPropValue('Negated', ...
                    'Must be a logical scalar'));
            end
            obj.Negated = value;
            
        end
        
        
    end
    
    
    % physioset.event.selector.selector interface
    methods
        
        function obj = not(obj)
            
            obj.Negated = ~obj.Negated;
            
        end
        
        function [evArray, idx] = select(obj, evArray)
            
            selected = true(size(evArray));
            
            if ~isempty(obj.Class),
                fullClassName = cellfun(@(x) ['physioset.event.std.' x], ...
                    obj.Class, 'UniformOutput', false);
                
                af = @(x) goo.pkgisa(x, fullClassName);
                
                selected = selected & arrayfun(af, evArray);
            end
            
            
            if isempty(obj.Type),                
                
                thisSelected = true(size(selected));
                
            else
                
                thisSelected = false(size(selected));
                for i = 1:numel(obj.Type),
                    regex = obj.Type{i};
                    af = @(x) ~isempty(regexp(get(x, 'Type'), regex, 'once'));
                    
                    thisSelected = thisSelected | arrayfun(af, evArray);
                end               
                
            end
            
            selected = selected & thisSelected;
            
            if obj.Negated,
                selected = ~selected;
            end
            
            evArray = evArray(selected);
            
            idx = find(selected);
            
        end
        
    end
    
    % Constructor
    methods
        
        function obj = class_selector(varargin)
            
            import misc.process_arguments;
            
            obj = obj@physioset.event.abstract_selector(varargin{:});
            
            if nargin < 1, return; end
            
            opt.Class = {};
            opt.Type  = {};
            
            [~, opt] = process_arguments(opt, varargin);
            
            obj.Class = opt.Class;
            obj.Type  = opt.Type;
         
        end
        
    end
    
end