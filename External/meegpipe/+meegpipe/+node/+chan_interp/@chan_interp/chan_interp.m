classdef chan_interp < meegpipe.node.abstract_node
    % CHAN_INTERP - Bad channel interporlation
    %
    % import meegpipe.node.chan_interp.*;
    % obj = chan_interp;
    % obj = chan_interp('key', value, ...);
    %
    % ## Accepted key/value pairs:
    %
    % * All key/value pairs accepted by abstract_node
    %
    % * All key/value pairs accepted by meegpipe.node.chan_interp.config
    %
    %
    % See also: config, abstract_node
    
    methods (Access = private)
        make_interpolation_report(obj, chanGroups, data, badIdx, A);
    end
    
    methods
        % meegpipe.node.node interface
        [data, dataNew] = process(data, varargin);
    end
    
    
    % Constructor
    methods
        
        function obj = chan_interp(varargin)
            
            import pset.selector.sensor_class;
            import pset.selector.good_data;
            import pset.selector.cascade;
            import misc.prepend_varargin;
            
            dataSel = sensor_class('Class', {'EEG', 'MEG'});
            varargin = prepend_varargin(varargin, 'DataSelector', dataSel);  
            
            obj = obj@meegpipe.node.abstract_node(varargin{:});
            
            if nargin > 0 && ~ischar(varargin{1}),
                % copy construction: keep everything like it is
                return;
            end
            
            if isempty(get_name(obj)),
                obj = set_name(obj, 'chan_interp');
            end
            
        end
        
    end
    
    
end