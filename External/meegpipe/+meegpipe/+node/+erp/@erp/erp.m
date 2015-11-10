classdef erp < meegpipe.node.abstract_node
    % erp - Compute average ERPs
    %
    % See: <a href="matlab:misc.md_help('meegpipe.node.erp')">misc.md_help(''meegpipe.node.erp'')</a>

    properties (SetAccess = private, GetAccess = private)
        
        ERPWaveform;
        ERPSensors;
        ERPFeatures;
        ERPSensorsImgIdx;
        
    end
  
    % from meegpipe.node.abstract_node
    methods
        [data, dataNew] = process(obj, data, varargin)
    end
    
    % redefinition of report.reportable method whatfor()
    methods
        
        function str = whatfor(~)
            
            str = 'Nodes of class __erp__ compute average ERPs ';
            
        end
        
    end
    
    % Other public methods (declared and defined here)
    methods
        
        function wv = get_erp_waveform(obj)
            
            wv = obj.ERPWaveform;
            
        end
        
        function [sens, idx] = get_erp_sensors(obj)
            
            sens = obj.ERPSensors;
            idx  = obj.ERPSensorsImgIdx;
            
        end
        
        function feat = get_erp_features(obj)
            
            feat = obj.ERPFeatures;
            
        end
        
    end
    
    % Constructor
    methods
        
        function obj = erp(varargin)
            
            import pset.selector.cascade;
            import pset.selector.good_samples;
            import pset.selector.sensor_class;
            import misc.prepend_varargin;
            
            dataSel = sensor_class('Type', {'EEG', 'MEG'});
            varargin = prepend_varargin(varargin, 'DataSelector', dataSel);  
            
            obj = obj@meegpipe.node.abstract_node(varargin{:});
            
            if nargin > 0 && ~ischar(varargin{1}),
                % copy construction: keep everything like it is
                return;
            end
            
            if isempty(get_name(obj)),
                obj = set_name(obj, 'erp');
            end           
            
        end
        
    end
    
    
end