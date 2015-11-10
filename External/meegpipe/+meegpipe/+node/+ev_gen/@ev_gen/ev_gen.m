classdef ev_gen < meegpipe.node.abstract_node
    % ev_gen - Event generation
    %
    % See: <a href="matlab:misc.md_help('meegpipe.node.ev_gen')">misc.md_help(''meegpipe.node.ev_gen'')</a>
    
    % from meegpipe.node.abstract_node
    methods
        [data, dataNew] = process(obj, data, varargin)
    end
    
    % redefinition of report.reportable method whatfor()
    methods
        
        function str = whatfor(~)
            
            str = 'Nodes of class __ev_gen__ generate events ';
            
        end
        
    end
    
    
    % Constructor
    methods
        
        function obj = ev_gen(varargin)
            
            import pset.selector.good_data;
            import misc.prepend_varargin;
            
            varargin = prepend_varargin(varargin, ...
                'DataSelector', good_data);
            
            obj = obj@meegpipe.node.abstract_node(varargin{:});
            
            if nargin > 0 && ~ischar(varargin{1}),
                % copy construction: keep everything like it is
                return;
            end
            
            if isempty(get_name(obj)),
                obj = set_name(obj, 'ev_gen');
            end
            
        end
        
    end
    
    
end