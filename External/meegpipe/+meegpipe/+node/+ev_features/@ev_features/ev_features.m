classdef ev_features < meegpipe.node.abstract_node
    % ev_features - Extract event features
    %
    % See: <a href="matlab:misc.md_help('meegpipe.node.ev_features')">misc.md_help(''meegpipe.node.ev_features'')</a>

    
    %% PUBLIC INTERFACE ...................................................
    
    % from meegpipe.node.abstract_node
    methods
        [data, dataNew] = process(obj, data, varargin)
    end
    
    % redefinition of report.reportable method whatfor()
    methods
        
        function str = whatfor(~)
            
            str = ['Nodes of class __ev_features__ extract features ' ...
                'from an array of events.'];
            
        end
        
    end    
   
    % Constructor
    methods
        
        function obj = ev_features(varargin)           
           
            obj = obj@meegpipe.node.abstract_node(varargin{:});
            
            if nargin > 0 && ~ischar(varargin{1}),               
                return;
            end
            
            if isempty(get_name(obj)),
                obj = set_name(obj, 'ev_features');
            end
           
        end
        
    end
    
    
end