classdef xcorr < meegpipe.node.bad_channels.criterion.rank.rank
    % XCORR - Cross-correlation criterion for bad channels selection
    %
    % This class is intentended to be use for the construction of 
    % bad_channels processing nodes. 
    %
    % ## Usage synopsis:
    %
    % % Build the criterion
    % import meegpipe.node.bad_channels.criterion.xcorr.xcorr;
    % myCrit = xcorr('NN', 10);
    % 
    % % Use it to build a bad_channels node
    % import meegpipe.node.bad_channels.bad_channels;
    % myNode = bad_channels('Criterion', myCrit);
    %
    %
    % ## Accepted (optional) construction key/value pairs:
    %
    %    * All key/value pairs accepted by the corresponding configuration
    %    class: meegpipe.node.bad_channels.criterion.xcorr.config
    %
    % See also: config, bad_channels
    

    methods
        
        [idx, rankVal] = compute_rank(obj, data);
        
    end
    
   % Constructor
    methods
        
        function obj = xcorr(varargin)
           
            obj = obj@meegpipe.node.bad_channels.criterion.rank.rank(...
                varargin{:});     
            
            
           
        end
        
    end
    
    
    
end