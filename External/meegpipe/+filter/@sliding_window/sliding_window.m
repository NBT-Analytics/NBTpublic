classdef sliding_window< ...
        filter.dfilt                & ...
        filter.rfilt                & ...
        goo.verbose                 & ...
        goo.abstract_setget         & ...
        goo.abstract_named_object
    
    
    properties
        Filter          = [];
        WindowLength    = @(sr) round(30*sr);  % In data samples
        WindowOverlap   = 50;                  % In percentage
        WindowFunction  = @hamming;            % See help window
    end
    
    methods
        y = filter(obj, x, varargin);   
        
        function y = filtfilt(obj, x, varargin)
            y = filter(obj, x, varargin{:});
        end
    end
    
    % Constructor
    methods
        
        function obj = sliding_window(varargin)
            
            import misc.process_arguments;
            
            if nargin < 1, return; end
            
            if isa(varargin{1}, 'filter.dfilt') || ...
                    isa(varargin{1}, 'filter.rfilt'),
                varargin = [{'Filter'}, varargin];
            end
            
            opt.Filter         = [];
            opt.WindowLength   = @(sr) round(30*sr); % In data samples
            opt.WindowOverlap  = 50;                 % In percentage
            opt.WindowFunction = @hamming;
            opt.Name           = 'sliding_window';
            opt.Verbose        = true;
            
            [~, opt] = process_arguments(opt, varargin, [], true);
            
            obj.Filter         = opt.Filter;
            obj.WindowLength   = opt.WindowLength;
            obj.WindowOverlap  = opt.WindowOverlap;
            obj.WindowFunction = opt.WindowFunction;
            
            obj = set_name(obj, opt.Name);
            obj = set_verbose(obj, opt.Verbose);
            
        end
        
        
    end
    
   
end