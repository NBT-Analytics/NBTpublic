classdef pca < ...
        filter.dfilt                & ...
        filter.rfilt                & ...
        goo.verbose                 & ...
        goo.abstract_setget         & ...
        goo.abstract_named_object
    % PCA - Spatial PCA filtering
    
    
    properties
        
        PCA      = spt.pca('RetainedVar', 99);
        PCFilter = []; % Should the PCs be filtered before back-projecting?
        
    end
    
    
    methods
        % filter.dfilt interface
        [y, obj] = filter(obj, x, d, varargin);
        
        function [y, obj] = filtfilt(obj, x, varargin)
            
            [y, obj] = filter(obj, x, varargin{:});
            
        end
        
        % Redefinitions of methods from goo.verbose
        function obj = set_verbose(obj, bool)
            obj = set_verbose@goo.verbose(obj, bool);
            if ~isempty(obj.PCFilter),
                obj.PCFilter = set_verbose(obj.PCFilter, bool);
            end
        end
    end
    
    % Constructor
    methods
        
        function obj = pca(varargin)
            
            import misc.process_arguments;
            
            if nargin < 1, return; end
            
            if isa(varargin{1}, 'filter.dfilt') || ...
                    isa(varargin{1}, 'filter.rfilt'),
                varargin = [{'PCFilter'}, varargin];
            end
            
            opt.PCA      = spt.pca('MaxCard', 5);
            opt.PCFilter = [];
            opt.Name     = 'filter.pca';
            opt.Verbose  = true;
            
            [~, opt] = process_arguments(opt, varargin);
            
            obj.PCFilter = opt.PCFilter;
            obj.PCA      = opt.PCA;
            
            obj = set_name(obj, opt.Name);
            obj = set_verbose(obj, opt.Verbose);
            
        end
        
        
    end
    
end