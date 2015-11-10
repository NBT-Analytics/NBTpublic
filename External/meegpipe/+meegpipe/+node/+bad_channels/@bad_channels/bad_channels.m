classdef bad_channels < meegpipe.node.abstract_node
    % bad_channels - Bad channel rejection
    %
    % See: <a href="matlab:misc.md_help('meegpipe.node.bad_channels')">misc.md_help(''meegpipe.node.bad_channels'')</a>
  
    methods
        % meegpipe.node.node interface
        [data, dataNew] = process(data, varargin);
        
        % reimplementation
        disp(obj);
        
        
    end
    
    methods (Access = protected)
        
        % override from abstract_node
        function bool = has_runtime_config(~)
            bool = true;
        end
        
    end
    
    % Constructor
    methods
        
        function obj = bad_channels(varargin)
            
            import pset.selector.sensor_class;
            import pset.selector.good_data;
            import pset.selector.cascade;
            import misc.prepend_varargin;
            
            dataSel1 = sensor_class('Class', {'EEG', 'MEG'});
            dataSel2 = good_data;
            dataSel  = cascade(dataSel1, dataSel2);
            varargin = prepend_varargin(varargin, 'DataSelector', dataSel);
            
            obj = obj@meegpipe.node.abstract_node(varargin{:});
            
            if nargin > 0 && ~ischar(varargin{1}),
                % copy construction: keep everything like it is
                return;
            end
            
            if isempty(get_name(obj)),
                obj = set_name(obj, 'bad_channels');
            end
            
        end
        
    end
    
end