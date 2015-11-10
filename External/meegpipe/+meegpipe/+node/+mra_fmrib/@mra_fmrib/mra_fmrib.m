classdef mra_fmrib < meegpipe.node.abstract_node
    % MRA_FMRIB - MR gradient artifact removal using FMRIB's toolbox
    %
    % import meegpipe.*;
    %
    % obj = node.mra_fmrib.new('key', value, ...);
    %
    % data = run(obj, data);
    %
    % Where
    %
    % DATA is a physioset object.
    %
    %
    % ## Accepted key/value pairs:
    %
    % * The constructor of the mra_fmrib node admits all the key/value
    %   pairs admitted by the abstract_node class.
    %
    % * For configuration options specific to this node class, see:
    %   help meegpipe.node.mra_fmrib.config
    %
    % See also: config, abstract_node
    
    
    % from meegpipe.node.abstract_node
    methods
        [data, dataNew] = process(obj, data, varargin)
    end
    
    % redefinition of report.reportable method whatfor()
    methods
        
        function str = whatfor(~)
            
            str = ['Nodes of class __mra_fmrib__ remove MR gradient artifacts ' ...
                'using FMRIB''s implementation of the FASTR method'];
            
        end
        
    end
    
    % Constructor
    methods
        
        function obj = mra_fmrib(varargin)
            
            import pset.selector.cascade;
            import pset.selector.good_data;
            import pset.selector.sensor_class;
            import report.plotter.io;
            import misc.prepend_varargin;

            dataSel = cascade(good_data, ...
                sensor_class('Type', {'EEG', 'ECG'}));
            varargin = prepend_varargin(varargin, 'DataSelector', dataSel);       
            
            obj = obj@meegpipe.node.abstract_node(varargin{:});
            
            if nargin > 0 && ~ischar(varargin{1}),
                % copy construction: keep everything like it is
                return;
            end
            
            if isempty(get_name(obj)),
                obj = set_name(obj, 'mra_fmrib');
            end
            
        end
        
    end
    
    
    
    
    
end