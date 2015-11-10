classdef config < meegpipe.node.abstract_config
    % CONFIG - Configuration for bad channels rejection criterion rank
    %
    % See: <a href="matlab:misc.md_help('meegpipe.node.bad_channels.criterion.rank')">misc.md_help(''meegpipe.node.bad_channels.criterion.rank'')</a>
    
    
    properties
        
        MinCard     = 0;
        MaxCard     = @(rank) ceil(0.2*numel(rank));
        Min         = @(rank) median(x)-10*mad(rank);
        Max         = @(rank) median(x)+4*mad(rank);
        RankPlotStats   = ...
            meegpipe.node.bad_channels.criterion.rank.default_plot_stats;
        
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
                obj.MaxCard = @(rank) ceil(0.2*numel(rank));
                return;
            end
            
            if numel(value) ~= 1 || ...
                    (~isnumeric(value) && ~isa(value, 'function_handle')),
                throw(InvalidPropValue('MaxCard', ...
                    'Must be a natural scalar or function_handle'));
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
                    'Must be a natural scalar of function_handle'));
            end
            
            obj.MinCard = value;
            
        end
        
    end
    
    
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@meegpipe.node.abstract_config(varargin{:});
            
            
        end
        
    end
    
    
    
end