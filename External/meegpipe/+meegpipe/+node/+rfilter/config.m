classdef config < meegpipe.node.abstract_config
    % CONFIG - Configuration for node rfilter
   
  
    properties
        
        Filter           = filter.mlag_regr;
        ExpandBoundary   = [2 2];   % left/right expand in % of segment length
        ChopSelector     = [];      % a pset.event.selector
        ReturnResiduals  = false;
        NbChannelsReport = 10;
        EpochDurReport   = 50;      % In seconds
        ShowDiffReport   = false;
        PCA              = [];
        TargetSelector   = [];   
        RegrSelector     = [];
        RegrPreFilter    = []; % Pre-filtering of the regressors
        
    end
    
    % Consistency checks (to be done)
    methods
       
        function set.Filter(obj, value)
            import exceptions.*;
            
            if isempty(value),
                obj.Filter = [];
                return;
            end
            
            if ~isa(value, 'filter.rfilt') && ...
                    ~isa(value, 'function_handle'),
                throw(InvalidPropValue('Filter', ...
                    'Must be a filter.rfilt object or a function_handle'));
            end
         
            obj.Filter = value;
            
        end
        
        function set.ChopSelector(obj, value)
            import exceptions.InvalidPropValue;
            
            if isempty(value),
                obj.ChopSelector = [];
                return;
            end
            
            if ~isa(value, 'physioset.event.selector'),
                throw(InvalidPropValue('ChopSelector', ...
                    'Must be an event selector object'));
            end
            
            obj.ChopSelector = value;
        end
        
        function set.ExpandBoundary(obj, value)
           import exceptions.InvalidPropValue;
           
           if isempty(value),
               obj.ExpandBoundary = [2 2];
               return;
           end
           
           if numel(value) == 1,
               value = repmat(value, 1, 2);
           end
           
           if ~isnumeric(value) || numel(value) ~= 2 || any(value < 0),
               throw(InvalidPropValue('ExpandBoundary', ...
                   'Must be a 1x2 numeric array of percentages'));
           end           
         
           obj.ExpandBoundary = reshape(value, 1, 2);            
            
        end
        
    end
   
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@meegpipe.node.abstract_config(varargin{:});            
           
        end
        
    end
    
    
    
end