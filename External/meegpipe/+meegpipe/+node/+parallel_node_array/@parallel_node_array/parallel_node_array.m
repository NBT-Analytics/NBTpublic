classdef parallel_node_array < meegpipe.node.abstract_node
    % PARALLEL_NODE_ARRAY - A parallel array of nodes
    
    methods (Static, Access = private)
        
        gal = generate_filt_plot(rep, idx, data1, data2, samplTime, gal, showDiff);
        
    end
    
    % meegpipe.node.node interface
    methods
        [data, dataNew] = process(obj, data, varargin)
    end
    
    % Constructor
    methods
        function obj = parallel_node_array(varargin)      
      
            obj = obj@meegpipe.node.abstract_node(varargin{:});
            
            nodeList = get_config(obj, 'NodeList');
            for i = 1:numel(nodeList),
                if isempty(nodeList{i}), continue; end
                nodeList{i} = clone(nodeList{i});
                nodeList{i}.GenerateReport = ...
                    nodeList{i}.GenerateReport & do_reporting(obj);
            end
            
            for i = 1:numel(nodeList)
                if isempty(nodeList{i}), continue; end
                childof(nodeList{i}, obj, i);
            end
            set_config(obj, 'NodeList', nodeList);
            
            if nargin > 0 && ~ischar(varargin{1}),
                % copy construction: keep everything else like it is
                return;
            end
            
            if isempty(get_name(obj)),
                set_name(obj, 'parallel_node_array');
            end
            

        end
    end
    
    
end