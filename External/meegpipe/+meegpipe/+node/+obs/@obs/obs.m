classdef obs < meegpipe.node.abstract_node
    % OBS - Optimal Basis Set for BCG correction
    %
    % import meegpipe.node.obs.*;
    %
    % obj = obs('key', value, ...);
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
    % * Class obs admits all the key/value pairs admitted by the
    %   abstract_node class. For detrend-specific keys see the help of
    %   meegpipe.node.obs.config.
    %
    % See also: config, abstract_node
    

    properties (SetAccess = private, GetAccess = private)
        ERPMean_;     % The mean BCG ERP
        ERPVar_;      % The variance of the BCG ERP
    end
   
    % from meegpipe.node.abstract_node
    methods
        [data, dataNew] = process(obj, data, varargin)
    end
    
    % redefinition of report.reportable method whatfor()
    methods
        
        function str = whatfor(~)
            
            str = ['Nodes of class __obs__ remove BCG artifacts ' ...
                'using an Optimal Basis Set '];
            
        end
        
    end
    
    % Other public methods which are specific to this node
    methods
        
        function [erpM, erpV] = get_bcg_erp(obj)
            
            erpM = obj.ERPMean_;
            erpV = obj.ERPVar_;

        end
        
        
    end
    
    % Constructor
    methods
        
        function obj = obs(varargin)
            
            import pset.selector.cascade;
            import pset.selector.good_data;
            import pset.selector.sensor_class;
            import report.plotter.io;
            import misc.prepend_varargin;
            
            dataSel = cascade(good_data, sensor_class('Type', 'EEG'));
            varargin = prepend_varargin(varargin, 'DataSelector', dataSel);       
            obj = obj@meegpipe.node.abstract_node(varargin{:});
            
            if nargin > 0 && isa(varargin{1}, 'meegpipe.node.obs.obs'),
                % copy construction: keep everything like it is
                obj.ERPMean_ = varargin{1}.ERPMean_;
                obj.ERPVar_  = varargin{1}.ERPVar_;
                return;
            end
            
            if isempty(get_name(obj)),
                obj = set_name(obj, 'obs');
            end
            
            if isempty(get_io_report(obj)),
                set_io_report(obj, io);
            end
            
        end
        
    end
    
    
    
    
    
end