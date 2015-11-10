classdef tstat < spt.feature.feature & goo.verbose
    % TSTAT - Time-domain statistic
    
    properties
        Stat           = []; % [] means: @(x) x      
        WindowLength   = []; % [] means: 1 sample. Otherwise, in seconds
        WindowOverlap  = 0;  % percentage
    end
    
    methods
        
        % spt.feature.feature interface
        function [featVal, featName] = extract_feature(obj, ~, ...
                tSeries, ~, varargin)
            
            if isempty(obj.Stat),
                % Get the raw data, WindowLength and WindowOverlap are
                % ignored
                featName = []; 
                featVal  = tSeries';
            else
                throw(exceptions.NotImplemented);
            end            
            
        end
        
        % Constructor
        
        function obj = tstat(varargin)
            import misc.set_properties;
            
            if nargin < 1, return; end
            
            opt.Stat           = [];
            opt.WindowLength   = [];
            opt.WindowOverlap  = [];
            obj = set_properties(obj, opt, varargin);      
        end
        
    end
    
end