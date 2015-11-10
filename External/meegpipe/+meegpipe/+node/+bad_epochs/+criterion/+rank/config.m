classdef config < goo.abstract_setget_handle
    % CONFIG - Configuration for bad epochs rejection criterion rank
    %
    % See: <a href="matlab:misc.md_help('meegpipe.node.bad_epochs.criterion.rank')">misc.md_help(''meegpipe.node.bad_epochs.criterion.rank'')</a>
    
    
    
    
    properties
        
        MinCard             = 0;
        MaxCard             = Inf;
        Min                 = -Inf;
        Max                 = Inf;
        RankPlotStats       = ...
            meegpipe.node.bad_epochs.criterion.rank.default_plot_stats;
    end
    
    % Consistency checks
    methods
        
        function obj = set.RankPlotStats(obj, value)
            
            import exceptions.InvalidPropValue;
            
            if isempty(value),
                obj.RankPlotStats = [];
                return;
            end
            
            if ~isa(value, 'mjava.hash'),
                throw(InvalidPropValue('RankPlotStats', ...
                    'Must be an mjava.hash object'));
            end
           
            obj.RankPlotStats = value;
            
        end
        
        function obj = set.MaxCard(obj, value)
            
            import exceptions.*;
            import misc.isnatural;
            
            if isempty(value),
                obj.MaxCard = Inf;
                return;
            end
            
            if numel(value) ~= 1 || ...
                    (~isnumeric(value) && ~isa(value, 'function_handle')),
                throw(InvalidPropValue('MaxCard', ...
                    'Must be a natural scalar or a function_handle'));
            end
            
            obj.MaxCard = value;
            
        end
        
        function obj = set.MinCard(obj, value)
            
            import exceptions.*;
            import misc.isnatural;
            
            if isempty(value),
                obj.MinCard = 0;
                return;
            end
            
            if numel(value) ~= 1 || ...
                    (~isnumeric(value) && ~isa(value, 'function_handle')),
                throw(InvalidPropValue('MinCard', ...
                    'Must be a natural scalar or a function_handle'));
            end
            
            obj.MinCard = value;
            
        end
        
    end
    
    
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@goo.abstract_setget_handle(varargin{:});           
            
        end
        
    end
    
    
    
end