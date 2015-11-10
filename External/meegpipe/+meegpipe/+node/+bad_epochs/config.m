classdef config < meegpipe.node.abstract_config
    % CONFIG - Configuration of bad_epochs nodes
    %
    % See: <a href="matlab:misc.md_help('meegpipe.node.bad_epochs.config')">misc.md_help(''meegpipe.node.bad_epochs.config'')</a>
    
    
    properties
        
        Duration        = []; % Use the duration of the epoch events
        Offset          = []; % Use the offset of the epoch events
        EventSelector   = ...
            physioset.event.class_selector('Class', {'epoch_begin', 'trial_begin'});
        DeleteEvents    = false; % Should the epoch events be removed?
        Criterion       = meegpipe.node.bad_epochs.criterion.stat.stat;
        PreFilter       = []; % A filter to apply before identifying bad epochs
    end
    
    % Consistency checks
    methods
        
        function obj = set.Criterion(obj, value)
            
            import exceptions.*;
            
            if isempty(value),
                obj.Criterion = meegpipe.node.bad_epochs.criterion.stat.stat;
                return;
            end
            
            if ~isa(value, 'meegpipe.node.bad_epochs.criterion.criterion'),
                throw(InvalidPropValue('Criterion', ...
                    'Must be a criterion object'));
            end
            
            obj.Criterion = value;
            
        end
        
        function obj = set.PreFilter(obj, value)
            import exceptions.InvalidPropValue;
            
            if isempty(value),
                obj.PreFilter = [];
                return;
            end
            
            if ~isa(value, 'filter.dfilt') && ~isa(value, 'function_handle'),
                throw(InvalidPropValue('PreFilter', ...
                    'Must be a filter.dfilt object or a function_handle'));
            end
            obj.PreFilter = value;
            
        end
        
    end
    
    
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@meegpipe.node.abstract_config(varargin{:});
            
        end
        
    end
    
    
    
end