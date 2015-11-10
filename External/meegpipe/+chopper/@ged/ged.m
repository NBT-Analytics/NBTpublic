classdef ged < chopper.abstract_chopper & goo.reportable
    % GED - Data chopping using Generalized Eigenvalue Decomposition
    %
    % See also: chopper
    
    
    % Public inteface .....................................................
    
    properties
        
        NbEig;          
        WindowLength    = ...
            @(data) max(100, min(floor(size(data,2)/100), ...
                20*power(size(data,1),2)));
        WindowOverlap   = 95;   
        EmbedDim        = 1;
        EmbedDelay      = 1;
        MinChunkLength  = @(data) 100*power(size(data,1),2);  
        MaxNbChunks     = 200;
        PreFilter       = [];
        PostFilter      = [];
        InitDelta       = [];    
        
    end
    
    % chopper.chopper interface
    methods
        
        [bndry, index] = chop(obj, data, varargin);
        
    end
    
    % report.reportable interface
    methods
        
        [pName, pValue, pDescr]   = report_info(obj);
        
        function str = whatfor(~)
           
            str = sprintf(...
                ['Chops input data using a non-stationarity index based ' ...
                'on Generalized Eigenvalue Decomposition (GED)'] ...
                );
            
        end
        
    end
    
    % Constructor
    methods
        
        function obj = ged(varargin)
            import misc.process_arguments;
           
            opt.NbEig               = [];
            opt.WindowLength        = ...
                @(data) max(100, min(floor(size(data,2)/100), ...
                20*power(size(data,1),2)));
            opt.WindowOverlap       = 95;
            opt.EmbedDim            = 1;
            opt.EmbedDelay          = 1;
            opt.MinChunkLength      = @(data) 100*power(size(data,1),2);
            opt.PreFilter           = [];
            opt.PostFilter          = [];
            opt.InitDelta           = 5;
            
            [~, opt] = process_arguments(opt, varargin);
            
            obj.NbEig           = opt.NbEig;
            obj.WindowLength    = opt.WindowLength;
            obj.WindowOverlap   = opt.WindowOverlap;
            obj.EmbedDim        = opt.EmbedDim;
            obj.EmbedDelay      = opt.EmbedDelay;
            obj.MinChunkLength  = opt.MinChunkLength;
            obj.PreFilter       = opt.PreFilter;
            obj.PostFilter      = opt.PostFilter;
            obj.InitDelta       = opt.InitDelta;
            
        end
        
    end
    
end