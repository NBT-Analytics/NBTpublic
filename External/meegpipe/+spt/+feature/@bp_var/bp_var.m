classdef bp_var < spt.feature.feature & goo.verbose
    % BP_VAR - Backprojected variance statistic
    
    properties
        DataSelector = pset.selector.sensor_class({'EEG', 'MEG'});
        AggregatingStat  = @(spcVar, rawVar) spt.feature.bp_var.max_bp_relative_var(spcVar, rawVar);
    end
    
    methods (Static)
       y = max_bp_relative_var(spcVar, rawVar); 
    end
    
    methods
        
        % spt.feature.feature interface
        [idx, featName] = extract_feature(obj, sptObj, tSeries, raw, varargin)
        
        % Constructor
        function obj = bp_var(varargin)
            import misc.set_properties;
            
            if nargin < 1, return; end
            
            opt.DataSelector = pset.selector.sensor_class({'EEG', 'MEG'});
            opt.AggregatingStat  = @(spcVar, rawVar) spt.feature.bp_var.max_bp_relative_var(spcVar, rawVar);
            obj = set_properties(obj, opt, varargin);
        end
        
    end
    
end