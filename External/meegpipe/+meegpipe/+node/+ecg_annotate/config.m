classdef config < meegpipe.node.abstract_config
    % CONFIG - Configuration of ecg_annotate nodes
    %
    % See: <a href="matlab:misc.md_help('meegpipe.node.ecg_annotate.config')">misc.md_help(''meegpipe.node.ecg_annotate.config'')</a>
    
    
    methods (Access = private)
       
        % Global consistency check
        function check(obj)
           
            import exceptions.Inconsistent;
            if numel(obj.EventFeatures) ~= numel(obj.EventFeatureNames),
                throw(Inconsistent(['The number of event features must '  ...
                    'match the number of feature names']));
            end
            
        end
        
    end
    
    
    properties        
       
        EventSelector  = []; 
        EventFeatures  = {@(ev) get_name(ev(1))};
        EventFeatureNames = {'event_name'};
        RPeakEventSelector = physioset.event.class_selector('Class', 'qrs');
        
    end
    
    % Consistency checks
    methods
        
        function obj = set.EventFeatures(obj, value)
           
            import exceptions.InvalidPropValue;
            
            if isempty(value),
                obj.EventFeatures = {};
                return;
            end
            
            if ~iscell(value), value = {value}; end
            
            if ~all(cellfun(@(x) isa(x, 'function_handle'), value)),
                throw(InvalidPropValue('EventFeatures', ...
                    'Must be a cell array of function handles'));
            end            
            
            obj.EventFeatures = value;
        end
        
        function obj = set.EventFeatureNames(obj, value)
           
            import exceptions.InvalidPropValue;
            
            if isempty(value),
                obj.EventFeatureNames = {};
                return;
            end
            
            if ~iscell(value), value = {value}; end
            
            if ~all(cellfun(@(x) ischar(x), value)),
                throw(InvalidPropValue('EventFeatureNames', ...
                    'Must be a cell array of strings'));
            end            
            
            obj.EventFeatureNames = value;
            
        end
       
        function obj = set.EventSelector(obj, value)
           
            import exceptions.InvalidPropValue;
            
            if isempty(value),
                obj.EventSelector = [];
                return;
            end
            
            if isa(value, 'physioset.event.selector'),
                value = {value};
            end
            
            if ~iscell(value) || ~all(cellfun(@(x) ...
                    isa(x, 'physioset.event.selector'), value)),
                throw(InvalidPropValue('EventSelector', ...
                    'Must be a cell array of event selectors'));
            end
            
            obj.EventSelector = value;          
            
        end
        
        function obj = set.RPeakEventSelector(obj, value)
           
            import exceptions.InvalidPropValue;
            
            if isempty(value),
                obj.RPeakEventSelector = [];
                return;
            end
            
            if ~isa(value, 'physioset.event.selector'),
                throw(InvalidPropValue('RPeakEventSelector', ...
                    'Must be a cell array of event selectors'));
            end
            
            obj.RPeakEventSelector = value;          
            
        end
        
        
    end
    

    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@meegpipe.node.abstract_config(varargin{:});
            
            check(obj);
        end
        
    end
    
    
    
end