classdef equalize < meegpipe.node.abstract_node
    % EQUALIZE - Equalize ranges of various data modalities
    %

    
    methods
        
        [data, dataNew] = process(obj, data)
        
    end
    
    % Constructor
    methods
        
        function obj = equalize(varargin)       
           
            obj = obj@meegpipe.node.abstract_node(varargin{:});
            
            if nargin > 0 && ~ischar(varargin{1}),
                % Copy constructor
                return;
            end
            
            if isempty(get_name(obj)),
                obj = set_name(obj, 'equalize');
            end
            
        end
        
    end
    
    
end