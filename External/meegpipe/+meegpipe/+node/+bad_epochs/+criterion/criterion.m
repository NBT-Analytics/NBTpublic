classdef criterion
    % CRITERION - Interface for bad epochs rejection criteria
    %
    % See: <a href="matlab:misc.md_help('meegpipe.node.bad_epochs.criterion.criterion')">misc.md_help(''meegpipe.node.bad_epochs.criterion.criterion'')</a>

   
   
   
    methods (Abstract)
       
        [evBad, rejIx, samplIdx] = find_bad_epochs(obj, data, ev);
        
    end  
    
end