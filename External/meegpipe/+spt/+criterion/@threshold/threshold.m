classdef threshold < spt.criterion.criterion & goo.verbose & goo.abstract_named_object
    % THRESHOLD - Select components that exceed a threshold
    
    properties (SetAccess = private, GetAccess = private)
        FeatVals;
        Selected;
        RankIndex;
    end
    
    properties
        Negated = false;
        Feature = {};           % One or more feature objects
        Min     = -Inf;
        Max     = +Inf;
        MinCard = 0;
        MaxCard = Inf;
        FeatPlotStats = spt.criterion.threshold.default_plot_stats;
        SelectionAggregator = @(sel) prod(double(sel), 1) > 0; 
        RankingFactor = [];
    end
    
    methods (Static)
       
        hashObj = default_plot_stats();
        
        function obj = or(varargin)
           
            obj = spt.criterion.threshold(varargin{:}, ...
                'SelectionAggregator', @(sel) sum(double(sel), 1) > 0);
            
        end
        
    end
    
    
    methods
        
        % Consistency checks
        function check(obj)
            import exceptions.Inconsistent;
            
            if isempty(obj.Feature), return; end
            
            if (numel(obj.Feature) > 1 && numel(obj.Min) > 1) && ...
                    numel(obj.Feature) ~= numel(obj.Min),
                throw(Inconsistent(['There must be one Min threshold per ', ...
                    'feature']));
            end
            
            if (numel(obj.Feature) > 1 && numel(obj.Max) > 1) && ...
                    numel(obj.Feature) ~= numel(obj.Max),
                throw(Inconsistent(['There must be one Max threshold per ', ...
                    'feature']));
            end
            
            if numel(obj.RankingFactor) > 1 && ...
                    numel(obj.RankingFactor) ~= numel(obj.Feature),
                throw(Inconsistent(sprintf(['numel(RankingFactor)=%d '  ...
                    'does not match numel(Feature)=%d'], ...
                    numel(obj.RankingFactor), numel(obj.Feature))));
            end
            
        end
        
        function obj = set.FeatPlotStats(obj, value)
            
            import exceptions.InvalidPropValue;
            
            if isempty(value),
                obj.FeatPlotStats = [];
                return;
            end
            
            if ~isa(value, 'mjava.hash'),
                throw(InvalidPropValue('FeatPlotStats', ...
                    'Must be an mjava.hash object'));
            end
           
            obj.FeatPlotStats = value;
            
        end
        
        function obj = set.Negated(obj, value)
            import exceptions.InvalidPropValue;
            if isempty(value),
                obj.Negated = false;
                return;
            end
            
            if numel(value) ~= 1 || ~islogical(value),
                throw(InvalidPropValue('Negated', ...
                    'Must be a logical scalar'));
            end
            obj.Negated = value;
        end
        
        function obj = set.Feature(obj, value)
            import exceptions.InvalidPropValue;
            
            if isempty(value),
                obj.Feature = {};
                return;
            end
            
            if ~iscell(value),
                value = {value};
            end
            
            if ~all(cellfun(@(x) isa(x, 'spt.feature.feature'), value)),
                throw(InvalidPropValue('Feature', ...
                    'Must be a cell array of spt.feature.feature'));
            end
            obj.Feature = value;
            
        end
        
        function obj = set.Min(obj, value)
            import exceptions.InvalidPropValue;
            
            if isempty(value),
                obj.Min = -Inf;
                return;
            end
            
            if ~iscell(value),
                value = {value};
            end
            
            if ~all(cellfun(@(x) isa(x, 'function_handle') | ...
                    (isnumeric(x) & numel(x) == 1), ...
                    value)),
                throw(InvalidPropValue('Min', ...
                    'Must be a cell array of function_handle or scalars'));
            end
            obj.Min = value;
        end
         
        function obj = set.Max(obj, value)
            import exceptions.InvalidPropValue;
            
            if isempty(value),
                obj.Max = Inf;
                return;
            end
            
            if ~iscell(value),
                value = {value};
            end
            
            if ~all(cellfun(@(x) isa(x, 'function_handle') | ...
                    (isnumeric(x) & numel(x) == 1), ...
                    value)),
                throw(InvalidPropValue('Max', ...
                    'Must be a cell array of function_handle or scalars'));
            end
            obj.Max = value;
            
        end
        
        function obj = set.RankingFactor(obj, value)
           import exceptions.InvalidPropValue;
           
           if isempty(value),
               obj.RankingFactor = [];
               return;
           end
           
           if ndims(value) > 2 || all(size(value) > 1) || any(value < 0), %#ok<ISMAT>
               throw(InvalidPropValue('RankingFactor', ...
                   'Must be a numeric array of positive scalars'));
           end
           obj.RankingFactor = value;
        end
        
        
        % spt.criterion.criterion interface
        [selected, featVal, rankIdx, obj] = select(obj, objSpt, tSeries, varargin)
        
        count = fprintf(fid, critObj, varargin)
        
        function obj = not(obj)
            obj.Negated = ~obj.Negated;
        end
        
        function bool = negated(obj)
            bool = obj.Negated;
        end
        
        function featArray = get_feature_extractor(obj, idx)
            
            if nargin < 2,
                idx = 1:numel(obj.Feature);
            end
            if isempty(idx), 
                featArray = {};
                return;
            end
       
            featArray = obj.Feature(idx);
            
        end
        
        % Constructor
        function obj = threshold(varargin)
            import misc.set_properties;
            
            if nargin < 1, return; end
            
            % First input args can be features (convenient syntax)
            i = 0;
            while isa(varargin{i+1}, 'spt.feature.feature'),
                i = i + 1;
                if i == nargin
                    break
                end
            end
            opt.Feature = varargin(1:i);
            varargin = varargin(i+1:end);
         
            opt.Negated = false;
            opt.Min     = -Inf;
            opt.Max     = +Inf;
            opt.MinCard = 0;
            opt.MaxCard = Inf;
            opt.SelectionAggregator = @(sel) prod(double(sel), 1) > 0; 
            opt.RankingFactor = [];
            obj = set_properties(obj, opt, varargin);
            
            if numel(obj.Feature) > 1 && numel(obj.Min) == 1,
                obj.Min = repmat(obj.Min, 1, numel(obj.Feature));
            end
            
            if numel(obj.Feature) > 1 && numel(obj.Max) == 1,
                obj.Max = repmat(obj.Max, 1, numel(obj.Feature));
            end
            
            check(obj);
        end
        
    end
    
    
    
end