classdef tfd < spt.feature.feature & goo.verbose
    % TFD - Time-domain fractal dimension
    
    properties
        Algorithm = 'sevcik_mean';; %'katz','sevcik','katz_mean','sevcik_mean'
        WindowLength = @(sr) sr;
        WindowShift  = @(sr) sr;
    end
    
    % Static constructors
    methods (Static)
        function obj = eog(varargin)
           
            obj = spt.feature.tfd(...
                'WindowLength', @(sr) 2*sr, ...
                'WindowShift', @(sr) sr, ...
                varargin{:});   
        end
    end
    
    methods
        
        % spt.feature.feature interface
        function [featVal, featName] = extract_feature(obj, ~, tSeries, raw, varargin)
            
            import misc.fd;
            
            featName = [];
            
            if nargin < 4 || isempty(raw),
                sr = tSeries.SamplingRate;
            else
                sr = raw.SamplingRate;
            end
            
            cfg.method = obj.Algorithm;
            if isa(obj.WindowLength, 'function_handle'),
                cfg.wl = obj.WindowLength(sr);
            else
                cfg.wl = obj.WindowLength;
            end
            if isa(obj.WindowShift, 'function_handle'),
                cfg.ws = obj.WindowShift(sr);
            else
                cfg.ws = obj.WindowShift;
            end
            
            featVal = nan(size(tSeries,1), 1);
            for i = 1:size(tSeries,1)
                featVal(i) = fd(tSeries(i,:)', cfg);
            end
            
        end
        
        % Constructor
        
        function obj = tfd(varargin)
            import misc.set_properties;
            
            if nargin < 1, return; end
            
            opt.Algorithm = 'sevcik_mean'; %'katz','sevcik','katz_mean','sevcik_mean'
            opt.WindowLength = @(sr) sr;
            opt.WindowShift  = @(sr) sr;
            obj = set_properties(obj, opt, varargin);
        end
        
    end
    
    
    
end