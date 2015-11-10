classdef config < meegpipe.node.abstract_config
    % CONFIG - Configuration of erp nodes
    %
    % See: <a href="matlab:misc.md_help('meegpipe.node.erp.config')">misc.md_help(''meegpipe.node.erp.config'')</a>
 
    
    properties
        
        EventSelector     = physioset.event.class_selector('Type', 'erp')
        Features          = {'Type', 'Sample', 'Time', 'Duration'};
        FeatureValues     = mjava.hash('Time', @(ev, data) get_abs_sampling_time(data, get_sample(ev)));
        Feature2String    = mjava.hash('Time', @(x) datestr(x));
        
    end
    
    % Consistency checks
    
    methods
        
        function obj = set.EventSelector(obj, value)
            
            import exceptions.*;
            
            if isempty(value),
                value = physioset.event.class_selector('Type', 'erp');
            end
            
            if numel(value) ~= 1 || ...
                    ~isa(value, 'physioset.event.selector'),
                throw(InvalidPropValue('EventSelector', ...
                    'Must be an event selector object'));
            end
            
            obj.EventSelector = value;
            
            
        end        
       
    end
    
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@meegpipe.node.abstract_config(varargin{:});
            
        end
        
    end
    
    
end