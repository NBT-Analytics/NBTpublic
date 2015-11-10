classdef merge < meegpipe.node.abstract_node
    % merge - merge physioset into smaller physiosets
    %
    % See: <a href="matlab:misc.md_help('meegpipe.node.merge')">misc.md_help(''meegpipe.node.merge'')</a>
    
    methods
        
        % required by parent meegpipe.node.abstract_node
        [data, dataNew] = process(obj, data)
        
    end
    
    % redefinition of report.reportable method whatfor()
    methods
        
        function str = whatfor(~)
            
            str = ['Nodes of class _merge_ merge several data files ' ...
                'into a single physioset object'];
            
        end
        
        function fileName = get_output_filename(obj, data)
            
            if iscell(data),
                data = data{1};
            end
            fileName = ...
                get_output_filename@meegpipe.node.abstract_node(obj, data);
        end
        
    end
    
    
    methods
        function obj = merge(varargin)
            
            import exceptions.*;
            
            obj = obj@meegpipe.node.abstract_node(varargin{:});
            
            if nargin > 0 && ~ischar(varargin{1}),
                % copy construction: keep everything like it is
                return;
            end
            
            if isempty(get_name(obj)),
                obj = set_name(obj, 'merge');
            end
            
        end
    end
    
end