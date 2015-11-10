classdef operator < meegpipe.node.abstract_node
    % OPERATOR - Apply operator to physioset object
    %

    
    methods
        
        [data, dataNew] = process(obj, data)
        
    end
    
    % Constructor
    methods
        
        function obj = operator(varargin)       
           
            obj = obj@meegpipe.node.abstract_node(varargin{:});
            
            if nargin > 0 && ~ischar(varargin{1}),
                % Copy constructor
                return;
            end
            
            if isempty(get_name(obj)),
                obj = set_name(obj, 'operator');
            end
            
        end
        
    end
    
    
end