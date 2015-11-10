classdef cascade_selector < physioset.event.abstract_selector
    % CASCADE_SELECTOR - Cascade several event selectors
    %
    %
    %
    %
    % See also: physioset.event
    
    
    % PUBLIC INTERFACE ....................................................
    properties
        
        SelectorList;
        Negated;
        
    end
    
    methods
        
        function obj = set.SelectorList(obj, value)
            
            import exceptions.InvalidPropValue;
            
            if ~iscell(value), value = {value}; end
            
            isEvSel = cellfun(@(x) isa(x, 'physioset.event.selector'), value);
            
            if ~all(isEvSel),
                throw(InvalidPropValue('SelectorList', ...
                    'Must be a string/cell array of valid event name(s)'));
            end
            
            obj.SelectorList = value;
            
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
           
            for i = 1:numel(obj.SelectorList)               
                
                [~, thisIdx] = ...
                    select(obj.SelectorList{i}, evArray);
                
                selected(setdiff(1:numel(evArray), thisIdx)) = false;
            end
            
            if obj.Negated,
                selected = ~selected;
            end
            
            evArray = evArray(selected);
            
            idx = find(selected);
            
        end
        
    end
    
    % Constructor
    methods
        
        function obj = cascade_selector(varargin)      
            
            count = 0;
            while nargin > count && ...
                    isa(varargin{count+1}, 'physioset.event.selector')
                count = count + 1;                                
            end
            args4parent = varargin(count+1:end);
          
            obj = obj@physioset.event.abstract_selector(args4parent{:});
            
            obj.SelectorList = varargin;
          
        end
        
    end
    
end