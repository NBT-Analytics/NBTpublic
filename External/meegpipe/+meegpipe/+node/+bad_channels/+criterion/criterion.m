classdef criterion
    % CRITERION - Interface for bad channels rejection criteria
    %
    % See: <a href="matlab:misc.md_help('meegpipe.node.bad_channels.criterion.criterion')">misc.md_help(''meegpipe.node.bad_channels.criterion.criterion'')</a>
    
   
    methods (Abstract)
       
        [idx, rankVal] = find_bad_channels(obj, data, rep);
        
    end  
    
end