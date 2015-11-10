classdef center < meegpipe.node.abstract_node
    % CENTER - Removes mean of a dataset
    %
    %
    % obj = center;
    %
    % obj = center('key', value, ...)
    %
    %
    % ## Accepted construction arguments:
    %
    % * All the key/value pairs admitted by class abstract_node.
    %
    %
    % See also: abstract_node, node
    
    
    % from abstract_node
    methods
        
        [data, dataNew] = process(obj, data)
        
    end
    
    % Constructor
    methods
        
        function obj = center(varargin)
            import misc.prepend_varargin;
            
            dataSel = pset.selector.good_data;
            varargin = prepend_varargin(varargin, 'DataSelector', dataSel);      
            obj = obj@meegpipe.node.abstract_node(varargin{:});
            
            if nargin > 0 && ~ischar(varargin{1}),
                % copy construction: keep everything like it is
                return;
            end
            
            if isempty(get_name(obj)),
                obj = set_name(obj, 'center');
            end
            
        end
        
    end
    
    
end