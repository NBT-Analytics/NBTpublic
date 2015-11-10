classdef spectra < meegpipe.node.abstract_node
    % spectra - Compute signal spectra and spectral features
    %
    % See: <a href="matlab:misc.md_help('meegpipe.node.spectra')">misc.md_help(''meegpipe.node.spectra'')</a>
    
    
    properties (SetAccess = private, GetAccess = private)
        
        Spectra;
        SpectraSensors;
        SpectraSensorsIdx;
        SpectraFeatures;
        ChannelSets;
        
    end
    
    methods (Access = private)
        generate_spectra_images(obj, rep, plotter, data);
        [featNames, featM] = generate_spectra_topos(obj, rep, plotterObj, data);
    end
    
    methods (Access = private, Static)
        name = get_channel_set_name(chanSet);
    end
    
    % from meegpipe.node.abstract_node
    methods
        [data, dataNew] = process(obj, data, varargin)
    end
    
    % redefinition of report.reportable method whatfor()
    methods
        
        function str = whatfor(~)
            
            str = 'Nodes of class __spectra__ compute channel spectra ';
            
        end
        
    end
    
    % Other public methods (declared and defined here)
    methods
        
        function wv = get_spectra(obj)
            
            wv = obj.Spectra;
            
        end
        
        function [sens, idx] = get_spectra_sensors(obj)
            
            sens = obj.SpectraSensors;
            idx  = obj.SpectraSensorsIdx;
            
        end
        
        function feat = get_spectra_features(obj)
            
            feat = obj.SpectraFeatures;
            
        end
        
    end
    
    % Constructor
    methods
        
        function obj = spectra(varargin)
            
            import pset.selector.cascade;
            import pset.selector.good_samples;
            import pset.selector.sensor_class;
            import misc.prepend_varargin;
            
            dataSel1 = sensor_class('Type', {'EEG', 'MEG'});
            dataSel2 = good_samples;
            dataSel = cascade(dataSel1, dataSel2);
            varargin = prepend_varargin(varargin, 'DataSelector', dataSel);       
           
            obj = obj@meegpipe.node.abstract_node(varargin{:});
            
            if nargin > 0 && ~ischar(varargin{1}),
                % copy construction: keep everything like it is
                return;
            end
            
            if isempty(get_name(obj)),
                obj = set_name(obj, 'spectra');
            end
            
        end
        
    end
    
    
end