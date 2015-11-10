classdef lasip < ...
        filter.dfilt                & ...   
        goo.verbose                 & ...
        goo.abstract_setget         & ...
        goo.abstract_named_object
    
    properties
        
        Order;
        Gamma;
        Scales;
        WindowType;
        WeightsMedian;
        InterpMethod;
        GetNoise;     
        Decimation;
        ExpandBoundary;

    end
    
    % Consistency checks to be done later
    
    % filter.interface
    methods
        [y, obj] = filter(obj, x, varargin);
        
        function [y, obj] = filtfilt(obj, varargin)
           
            [y, obj] = filter(obj, varargin{:});
            
        end
    end    
    
    % Static constructors
    methods (Static)
       
        obj = eog(varargin);
        
    end
    
    % Constructor
    methods
        function obj = lasip(varargin)
            import misc.process_arguments;
            
            opt.Order            = 2;
            opt.Gamma            = 4:0.2:6;
            opt.Scales           = ceil([3 1.45.^(4:16)]);
            opt.WindowType       = ...
                {'Gaussian', 'GaussianLeft', 'GaussianRight'};
            opt.WeightsMedian    = [1 1 1 3 1 1 1];
            opt.InterpMethod     = 'spline';
            opt.GetNoise         = false;
            opt.Decimation       = 10;
            opt.ExpandBoundary   = 2;
            opt.Verbose          = false;
            opt.Name             = 'lasip';
            [~, opt] = process_arguments(opt, varargin);
            
            fNames = setdiff(fieldnames(opt), {'Verbose', 'Name'});
            for i = 1:numel(fNames)
                obj.(fNames{i}) = opt.(fNames{i});
            end
            
            obj = set_verbose(obj, opt.Verbose);
            obj = set_name(obj, opt.Name);
            
            % We set the verbosity level to something greater than usual
            % because this is a very slow filter and we want to generate
            % status messages in almost all occasions
            obj = set_verbose_level(obj, 2);
            
        end
        
    end
    
    
end