classdef psd_ratio < spt.feature.feature & goo.verbose
    % PSD_RATIO - Spectral power ratio
    
    properties
        TargetBand;
        RefBand;
        % IMPORTANT: this default estimator should match the default
        % estimator in physioset.plotter.psd.config. Otherwise the spectra
        % plotted in the report will not match the actual spectra used when
        % extracting the spectral power ratio features.
        Estimator  = @(x, sr) spt.feature.default_psd_estimator(x, sr);
        TargetBandStat = @(power) prctile(power, 75);
        RefBandStat = @(power) prctile(power, 25);
    end
    
    % Static constructors
    methods (Static)
        
        function obj = emg(varargin)
           obj = spt.feature.psd_ratio(...
               'TargetBand', [40 100], 'RefBand', [2 30]); 
        end
        
        function obj = eog(varargin)
           obj = spt.feature.psd_ratio(...
               'TargetBand',    [1 7;14 20], ...
               'RefBand',       [8 14;20 40], ...
               'TargetBandStat',@(power) prctile(power, 75), ...
               'RefBandStat',   @(power) max(power)); 
        end
        
        function obj = pwl(varargin)
            obj = spt.feature.psd_ratio(...
                'TargetBand',       [49 51], ...
                'RefBand',          [3 11], ...
                'TargetBandStat',   @(power) max(power), ...
                'RefBandStat',      @(power) prctile(power, 75)); 
        end
        
    end
    
    methods
        
        % spt.feature.feature interface
        [idx, featName] = extract_feature(obj, sptObj, tSeries, raw, varargin)
        
        % Constructor
        
        function obj = psd_ratio(varargin)
            import misc.set_properties;
            
            if nargin < 1, return; end
            
            opt.TargetBand = [];
            opt.RefBand = [];
            opt.Estimator  = ...
                @(x, sr) spt.feature.default_psd_estimator(x, sr);
            opt.TargetBandStat = @(power) prctile(power, 50);
            opt.RefBandStat = @(power) prctile(power, 50);
            obj = set_properties(obj, opt, varargin);      
        end
        
    end
    
end