classdef thilbert < spt.feature.feature & goo.verbose
    % THILBERT - Hilbert envelope stability
    
    
    properties
        Filter = []; % To be applied to the time-series before the HT
    end
    
    methods (Static)
        
        function obj = pwl(varargin)       
            myFilter = @(sr) filter.bpfilt('fp',  [45 55]/(sr/2));
            
            obj = spt.feature.thilbert('Filter', myFilter);
        end
        
    end
    
    methods
        
        % spt.feature.feature interface
        function [featVal, featName] = extract_feature(obj, ~, tSeries, varargin)
            featName = [];
            if ~isempty(obj.Filter) && isa(obj.Filter, 'function_handle'),
                filtObj = obj.Filter(tSeries.SamplingRate);
            else
                filtObj = obj.Filter;
            end
            
            featVal = nan(size(tSeries,1), 1);
            for i = 1:size(tSeries,1)
               this = tSeries(i,:) - mean(tSeries(i,:));
               this = this./sqrt(var(this));
               if ~isempty(obj.Filter),
                   this = filter(filtObj, this);
               end
               featVal(i) = var(abs(hilbert(this')));
            end
  
        end
        
        % Constructor
        function obj = thilbert(varargin)
            import misc.set_properties;
            
            if nargin < 1, return; end
            
            opt.Filter = [];
            obj = set_properties(obj, opt, varargin);
            
        end
        
    end
    
    
    
end