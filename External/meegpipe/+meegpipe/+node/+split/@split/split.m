classdef split < meegpipe.node.abstract_node
    % split - Split physioset into smaller physiosets
    %
    % See: <a href="matlab:misc.md_help('meegpipe.node.split')">misc.md_help(''meegpipe.node.split'')</a>
    
    methods
        
        % required by parent meegpipe.node.abstract_node
        [data, dataNew] = process(obj, data)
        
    end
    
    % redefinition of report.reportable method whatfor()
    methods
        
        function str = whatfor(~)
            
            str = ['Nodes of class _split_ split the input physioset ' ...
                'into several smaller subsets'];
            
        end
        
    end
    
    
    methods
        function obj = split(varargin)
            
            import exceptions.*;
            
            obj = obj@meegpipe.node.abstract_node(varargin{:});
            
            if nargin > 0 && ~ischar(varargin{1}),
                % copy construction: keep everything like it is
                return;
            end
            
            if isempty(get_name(obj)),
                obj = set_name(obj, 'split');
            end
            
        end
    end
    
end