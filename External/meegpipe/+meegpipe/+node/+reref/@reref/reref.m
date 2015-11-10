classdef reref < meegpipe.node.abstract_node
    % REREF - Re-referencing operator
    %
    %
    % obj = reref;
    %
    % obj = reref.avg;
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
        
        function obj = reref(varargin)
            
            import pset.selector.sensor_class;
            import pset.selector.good_data;
            import pset.selector.cascade;
            import misc.prepend_varargin;
            
            dataSel = sensor_class('Type', 'EEG');
            varargin = prepend_varargin(varargin, 'DataSelector', dataSel);       
  
            obj = obj@meegpipe.node.abstract_node(varargin{:});
            
            % Copy constructor (private properties only)
            if nargin == 1 && isa(varargin{1}, 'meegpipe.node.reref.reref'),              
                return;
            end            
            
            if isempty(get_name(obj)),
                obj = set_name(obj, 'reref');
            end
            
        end
        
    end
    
    
end