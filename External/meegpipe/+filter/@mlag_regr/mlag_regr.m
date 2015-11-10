classdef mlag_regr < ...
        filter.rfilt                & ...
        goo.verbose                 & ...
        goo.abstract_setget         & ...
        goo.abstract_named_object
    % MLAG_REGR - Multilag (non-adaptive) regression
    %
    % ## Usage synopsis:
    %
    % obj = bpfilt('key', value, ...)
    % y = mlag_regr(obj, x, d)
    %
    % Where
    %
    % OBJ is a mlag_regr object
    %
    % X is the input to the filter (a KxM numeric matrix).
    %
    % D is the desired filter output (a NxM numeric matrix).
    %
    %
    % ## Acepted key/value pairs:
    %
    %       Order : A natural scalar. Default: 3
    %           The number of lags to use in the regression filter.
    %
    %
    % See also: adaptfilt
    
    
    properties
        
        Order = 3;
        PCA   = [];
        
    end
    
    % filter.dfilt interface
    
    methods
        [y, obj] = filter(obj, x, varargin);
        
        function [y, obj] = filtfilt(obj, x, varargin)
            
            [y, obj] = filter(obj, x, varargin{:});
            
        end
    end
    
    
    % Constructor
    methods
        
        function obj = mlag_regr(varargin)
            
            import misc.process_arguments;
            
            opt.Order   = 3;
            opt.PCA     = [];
            opt.Name    = 'mlag_regr';
            opt.Verbose = true;
            
            [~, opt] = process_arguments(opt, varargin);
            
            obj.Order = opt.Order;
            obj.PCA   = opt.PCA;
            
            obj = set_name(obj, opt.Name);
            obj = set_verbose(obj, opt.Verbose);
            
        end
        
        
    end
    
    
    
    
end