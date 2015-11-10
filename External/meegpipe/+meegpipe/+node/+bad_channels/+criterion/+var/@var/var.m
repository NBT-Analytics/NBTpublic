classdef var < meegpipe.node.bad_channels.criterion.rank.rank
    % VAR - Variance criterion for bad channels selection
    %
    % This class is intentended to be use for the construction of 
    % bad_channels processing nodes. 
    %
    % ## Usage synopsis:
    %
    % % Build the criterion
    % import meegpipe.node.bad_channels.criterion.var.var;
    % myCrit = var('NN', 10);
    % 
    % % Use it to build a bad_channels node
    % import meegpipe.node.bad_channels.bad_channels;
    % myNode = bad_channels('Criterion', myCrit);
    %
    %
    % ## Accepted (optional) construction key/value pairs:
    %
    %    * All key/value pairs accepted by the corresponding configuration
    %    class: meegpipe.node.bad_channels.criterion.var.config
    %
    % See also: config, bad_channels

    % From criterion rank
    methods
        
        [idx, rankVal] = compute_rank(obj, data);
        
    end
    
   % Constructor
    methods
        
        function obj = var(varargin)
           
            obj = obj@meegpipe.node.bad_channels.criterion.rank.rank(...
                varargin{:});         
           
        end
        
    end
    
    
    
end