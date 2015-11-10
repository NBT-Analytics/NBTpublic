classdef stat < meegpipe.node.bad_epochs.criterion.rank.rank
    % stat - Definition of epochs rejection criterion stat
    %
    % See: <a href="matlab:misc.md_help('meegpipe.node.bad_epochs.criterion.stat')">misc.md_help(''meegpipe.node.bad_epochs.criterion.stat'')</a>
    
    
    % From criterion rank
    methods
        
        [idx, rankVal] = compute_rank(obj, data, ev);
        
    end
    
   % Constructor
    methods
        
        function obj = stat(varargin)
           
            obj = obj@meegpipe.node.bad_epochs.criterion.rank.rank(...
                varargin{:});         
           
        end
        
    end
    
    
    
end