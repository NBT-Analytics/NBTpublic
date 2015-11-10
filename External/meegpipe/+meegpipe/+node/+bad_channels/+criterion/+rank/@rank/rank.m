classdef rank < meegpipe.node.bad_channels.criterion.abstract_criterion
    % RANK - Definition of abstract channel rejection criterion rank
    %
    % See: <a href="matlab:misc.md_help('meegpipe.node.bad_channels.criterion.rank')">misc.md_help(''meegpipe.node.bad_channels.criterion.rank'')</a>
    
    
    % Helper methods
    methods (Access = private, Static)
        
        generate_rank_report(obj, data, rankIndex, rejIdx, minRank, ...
            maxRank, rankStats);
        
    end
    
    % Helper static methods
    methods (Access = private, Static)
        
        % To generate the figures of Remark reports
        hFig = make_topo_plots(sens, xvar, rejIdx);
        
        hFig = make_rank_plots(sens, xvar, rejIdx, minRank, maxRank, rankStats);
        
    end

    % criterion interface
    methods
        
        [idx, rankVal] = find_bad_channels(obj, data, rep);
        
    end
    
    methods (Abstract)
        
        idx = compute_rank(obj, data)
        
    end
    
    % Constructor
    methods
        
        function obj = rank(varargin)
            
            
            obj = ...
                obj@meegpipe.node.bad_channels.criterion.abstract_criterion(...
                varargin{:});
            
        end
        
    end
    
    
    
    
end