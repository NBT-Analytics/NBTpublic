classdef psd_peak < spt.feature.feature & goo.verbose
   % PSD_PEAK - PSD peak characteristics

   properties
       TargetBand;
       Estimator  = @(x, sr) spt.feature.default_psd_estimator(x, sr);
       MainFeature = 'Peakyness'; % Other options: Width, PeakFreq
   end

   methods (Static)

       function obj = alpha(varargin)
          obj = spt.feature.psd_peak('TargetBand', [7 12]);
       end
        function obj = pwl(varargin)
          obj = spt.feature.psd_peak('TargetBand', [48 52]);
       end

   end

   methods
        % spt.feature.feature interface
        [idx, featName] = extract_feature(obj, sptObj, tSeries, raw, varargin)

        % Constructor

        function obj = psd_peak(varargin)
            import misc.set_properties;

            opt.TargetBand = [];
            opt.Estimator  = ...
                @(x, sr) spt.feature.default_psd_estimator(x, sr);
            opt.MainFeature = 'Peakyness'; % Other options: Width, PeakFreq
            obj = set_properties(obj, opt, varargin);

            if isempty(obj.TargetBand),
                error('You must specify a TargetBand');
            end

        end

   end

end