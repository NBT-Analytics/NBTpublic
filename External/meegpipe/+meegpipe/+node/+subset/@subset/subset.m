classdef subset < meegpipe.node.abstract_node
    % bad_channels - Bad channel rejection
    %
    % See: <a href="matlab:misc.md_help('meegpipe.node.subset')">misc.md_help(''meegpipe.node.subset'')</a>
    
    methods
        
        % required by parent meegpipe.node.abstract_node
        [data, dataNew] = process(obj, data)
        
    end
    
    % redefinition of report.reportable method whatfor()
    methods
        
        function str = whatfor(~)
            
            str = ['Nodes of class _subset_ create a physioset from a ' ...
                'subset of the input physioset object.'];
            
        end
        
    end
    
    
    methods
        function obj = subset(varargin)
            
            import exceptions.*;
            
            obj = obj@meegpipe.node.abstract_node(varargin{:});
            
            if nargin > 0 && ~ischar(varargin{1}),
                % copy construction: keep everything like it is
                return;
            end
            
            if isempty(get_name(obj)),
                obj = set_name(obj, 'subset');
            end
            
        end
    end
    
end