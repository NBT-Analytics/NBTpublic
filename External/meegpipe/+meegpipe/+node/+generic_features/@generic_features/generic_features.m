classdef generic_features < meegpipe.node.abstract_node
    % generic_features - Extract pupil diameter features
    %
    % See: <a href="matlab:misc.md_help('meegpipe.node.generic_features')">misc.md_help(''meegpipe.node.generic_features'')</a>
    
    
    %% PUBLIC INTERFACE ...................................................
    
    % from meegpipe.node.abstract_node
    methods
        [data, dataNew] = process(obj, data, varargin)
    end
    
    % redefinition of report.reportable method whatfor()
    methods
        
        function str = whatfor(~)
            
            str = ['Nodes of class __generic_features__ extract generic ' ...
                'time-series features.'];
            
        end
        
    end
    
    % Constructor
    methods
        
        function obj = generic_features(varargin)
            
            import misc.prepend_varargin;
            
            dataSel = pset.selector.good_data;
            varargin = prepend_varargin(varargin, 'DataSelector', dataSel);  
        
            obj = obj@meegpipe.node.abstract_node(varargin{:});
            
            if nargin > 0 && ~ischar(varargin{1}),
                % copy construction: keep everything like it is
                return;
            end
            
            if isempty(get_name(obj)),
                obj = set_name(obj, 'generic_features');
            end
            
        end
        
    end
    
    
end