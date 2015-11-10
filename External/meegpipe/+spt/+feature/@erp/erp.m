classdef erp < spt.feature.feature & goo.verbose
    % ERP - Event Related Potential stability across trials
    
    properties
        EventSelector = []; % Select ERP events
        Offset        = []; % Taken from events if empty (in seconds)
        Duration      = []; % Taken from events if empty (in seconds)
        Filter        = []; % A pre-processing filter 
        CorrAggregationStat = @(x) prctile(abs(x), 75);
    end
    
    methods
       
        function obj = set.Filter(obj, value)
           import exceptions.InvalidPropValue;
           
           if isempty(value),
               obj.Filter = [];
               return;
           end
           
           if numel(value) ~= 1 || (~isa(value, 'filter.dfilt') && ...
                   ~isa(value, 'function_handle')),
               throw(InvalidPropValue('Filter', ...
                   'Must be a filter.dfilt or a function_handle'));
           end
           
           if isa(value, 'function_handle'),
              testVal = value(500);
              if ~isa(testVal, 'filter.dfilt'),
                  throw(InvalidPropValue('Filter', ...
                   'Must evaluate to a filter.dfilt object'));
              end
           end
           
           obj.Filter = value;            
        end
        
        function obj = set.EventSelector(obj, value)
           import exceptions.InvalidPropValue;
           
           if isempty(value),
               obj.EventSelector = [];
               return;
           end
           
           if numel(value) ~= 1 || ~isa(value, 'physioset.event.selector'),
               throw(InvalidPropValue('EventSelector', ...
                   'Must be an event selector'));
           end
           
           obj.EventSelector = value;
        end
        
    end
    
    
    % Static constructors
    methods (Static)
       
        function obj = bcg(varargin)
            
            mySel = physioset.event.class_selector('Class', 'qrs');
            myFilter = @(sr) filter.hpfilt('fp', 2/(sr/2));
            
            obj = spt.feature.erp(...
                'EventSelector',    mySel, ...
                'Offset',           -0.2, ...
                'Duration',         0.0, ...
                'Filter',           myFilter);
            
        end
        
    end
    
    methods
        
        % spt.feature.feature interface
        [featVal, featName] = extract_feature(~, sptObj, varargin)
        
        % Constructor
        function obj = erp(varargin)
            import misc.set_properties;
            
            if nargin < 1, return; end
            
            opt.EventSelector = []; 
            opt.Offset        = []; 
            opt.Duration      = []; 
            opt.Filter        = [];
            opt.CorrAggregationStat = @(x) prctile(abs(x), 75);
            obj = set_properties(obj, opt, varargin); 
        end
        
    end
    
    
    
end