classdef aregr < meegpipe.node.abstract_node
    % aregr - (Adaptive) regression
    %
    % See: <a href="matlab:misc.md_help('meegpipe.node.aregr')">misc.md_help(''meegpipe.node.aregr'')</a>
    
    
    
    %% PUBLIC INTERFACE ...................................................
    
    
    % meegpipe.node.node interface
    methods
        
        [data, dataNew] = process(obj, data, varargin);
        
    end
    
    % Static constructors
    methods (Static)
        
        obj = bcg(varargin);
        
    end
    
    % Constructor
    methods
        
        function obj = aregr(varargin)
            
            import exceptions.*;
            import pset.selector.good_data;
            import misc.prepend_varargin;
            
            dataSel = pset.selector.good_data;
            varargin = prepend_varargin(varargin, 'DataSelector', dataSel);  
            
            obj = obj@meegpipe.node.abstract_node(varargin{:});
            
            if nargin > 0 && ~ischar(varargin{1}),
                % copy construction: keep everything like it is
                return;
            end
            
            if isempty(get_name(obj)),
                obj = set_name(obj, 'aregr');
            end
            
        end
        
    end
    
end