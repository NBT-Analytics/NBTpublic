classdef tpca < ...
        filter.dfilt                & ...
        goo.verbose                 & ...
        goo.abstract_setget         & ...
        goo.abstract_named_object
    % TPCA - Temporal PCA filter
    %
    % ## Usage synopsis:
    %
    % obj = bpfilt('key', value, ...)
    % y = tpca(obj, x)
    %
    % Where
    %
    % OBJ is a tpca object
    %
    % X is the input to the filter (a KxM numeric matrix).
    %
    % Y is the filtered output (a KxM numeric matrix).
    %
    %
    % ## Acepted key/value pairs:
    %
    %       Order : A natural scalar. Default: 100
    %           The number of time lags to use to build the delay-embedded
    %           data matrix
    %
    %       PCA : A spt.pca.pca object. Default: spt.pca('MaxDimOut', 5)
    %           The PCA to be applied to the delay-embedded data matrix.
    %
    %
    % See also: filter
    
    
    properties
        
        Order    = 50;
        PCA      = spt.pca('MaxCard', 5);
        PCFilter = []; % Should the PCs be filtered before back-projecting?
        
    end
    
    methods
        
        % filter.dfilt interface
        [y, obj] = filter(obj, x, varargin);
        
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
        
        function obj = tpca(varargin)
            
            import misc.process_arguments;
            
            opt.Order    = 50;
            opt.PCA      = spt.pca('MaxCard', 5);
            opt.PCFilter = [];
            opt.Name     = 'filter.tpca';
            opt.Verbose  = true;
            
            [~, opt] = process_arguments(opt, varargin);
            
            obj.PCFilter = opt.PCFilter;
            obj.Order    = opt.Order;
            obj.PCA      = opt.PCA;
            
            obj = set_name(obj, opt.Name);
            obj = set_verbose(obj, opt.Verbose);
            
        end
        
        
    end
    

end