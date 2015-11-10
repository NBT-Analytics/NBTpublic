classdef data_selector < meegpipe.node.bad_channels.criterion.abstract_criterion
    % DATA_SELECTOR - Select bad channels using data selector
    
    % criterion interface
    methods
        
        function [idx, rankVal] = find_bad_channels(obj, data, ~)
            
            rankVal = zeros(1, size(data, 1));
            dataSel = get_config(obj, 'DataSelector');           
            [~, emptySel] = select(dataSel, data);          
            if emptySel,
                idx = [];
                % no need of restore_selection because for empty selections
                % no actual selecion is done
                return;
            end
            idx = relative_dim_selection(data);
            restore_selection(data);            
            rankVal(idx) = 1;
            
        end
        
    end
    
     % Constructor
    methods
        
        function obj = data_selector(varargin)
            
            import misc.process_arguments;
            import misc.split_arguments;
            import pset.selector.cascade;
            
            count = 0;
            while count < nargin && ...
                    isa(varargin{count+1}, 'pset.selector.selector'),
                count = count + 1;
            end
            if count == 1,
                varargin = [{'DataSelector', varargin{1}} ...
                    varargin(2:end)];
            elseif count > 1
                varargin = [{'DataSelector', cascade(varargin{1:count})} ...
                    varargin(count+1:end)];
            end
      
            obj = ...
                obj@meegpipe.node.bad_channels.criterion.abstract_criterion(...
                varargin{:});
   
        end
        
    end
    
end