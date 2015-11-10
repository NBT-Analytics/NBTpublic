classdef filter_fit < spt.feature.feature & goo.verbose
    
    properties
        Filter          = [];
    end
    
    methods (Static)
       
        function obj = lasip(varargin)
           
            myFilter = filter.lasip(varargin{:});
            
            myFilter = set_verbose(myFilter, false);
            myFilter = set_verbose_level(myFilter, 0);
            
            obj = spt.feature.filter_fit('Filter', myFilter);
            
        end
        
    end
    
    methods
       
        % Consistency
        function obj = set.Filter(obj, value)
            import exceptions.InvalidPropValue;
            
            if isempty(value)
                obj.Filter = [];
                return;
            end
            
            if numel(value) ~= 1 || ~isa(value, 'filter.dfilt'),
                throw(InvalidPropValue('Filter', ...
                    'Must be a filter.dfilt object'));
            end                
            
            obj.Filter = value;            
        end
        
        function [featVal, featName] = extract_feature(obj, ~, tSeries, ...
                varargin)           
            import exceptions.Inconsistent;
            
            featName = [];
            
            if isempty(obj.Filter),
                throw(Inconsistent(['Cannot extract fetures without ' ...
                    'setting property Filter']));
            end
            
            origVar = var(tSeries, [], 2);
            featVal = nan(size(tSeries,1), 1);
            
            verbose = is_verbose(obj);
            verboseLabel = get_verbose_label(obj);
            
            if verbose,
                fprintf([verboseLabel ...
                    'Finding %s filter fit for %d time-series ...'], ...
                    class(obj.Filter), size(tSeries,1));
            end       
            tinit = tic;
            for i = 1:size(tSeries,1)
                filtData = filter(obj.Filter, tSeries(i,:));
                featVal(i) = var(filtData)./origVar(i);               
                if is_verbose(obj),
                   misc.eta(tinit, size(tSeries, 1), i); 
                end
            end
            if verbose,
                fprintf('\n\n');
            end            
        end
        
        % Constructor
        function obj = filter_fit(varargin)
            import misc.set_properties;
            
            if nargin < 1, return; end
            
            opt.Filter = [];            
            obj = set_properties(obj, opt, varargin);
            
        end
        
        
    end
    
    
    
    
end