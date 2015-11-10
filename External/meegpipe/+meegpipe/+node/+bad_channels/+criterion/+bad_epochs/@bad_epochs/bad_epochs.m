classdef bad_epochs < meegpipe.node.bad_channels.criterion.abstract_criterion
    % BAD_EPOCHS - Reject bad channels that produce many epoch rejections
    %
    % See: <a href="matlab:misc.md_help('meegpipe.node.bad_channels.bad_epochs.bad_epochs')">misc.md_help(''meegpipe.node.bad_channels.bad_epochs.bad_epochs'')</a>
    
    % From parent class
    methods
        
        [idx, rankVal] = find_bad_channels(obj, data, rep);
        
    end
    
    % Constructor
    methods
        
        function obj = bad_epochs(varargin)
            
            obj = ...
                obj@meegpipe.node.bad_channels.criterion.abstract_criterion(...
                varargin{:});
            
        end
        
    end
    
    
    
end