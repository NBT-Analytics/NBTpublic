classdef dummy < meegpipe.node.abstract_node
   % DUMMY - A dummy node, which lets data pass transparently
   %
   % See also: meegpipe.node
    
   methods
        
        [data, dataNew] = process(obj, data)
        
    end
    
    % Constructor
    methods
        
        function obj = dummy(varargin)
            
            import misc.prepend_varargin;
            
            dataSel = pset.selector.good_data;
            varargin = prepend_varargin(varargin, 'DataSelector', dataSel);  
                 
            obj = obj@meegpipe.node.abstract_node(varargin{:});
            
            if nargin > 0 && ~ischar(varargin{1}),
                % Copy constructor
                return;
            end
           
            if isempty(get_name(obj)),
                % Set a default node name
                obj = set_name(obj, 'dummy');
            end
            
        end
        
    end
    
    
end