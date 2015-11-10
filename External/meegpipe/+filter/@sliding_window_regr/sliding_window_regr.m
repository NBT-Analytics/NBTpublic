classdef sliding_window_regr < ...
        filter.rfilt                & ...
        goo.verbose                 & ...
        goo.abstract_setget         & ...
        goo.abstract_named_object
    
    
    properties
        Filter          = filter.mlag_regr;    % A filter.dfilt or filter.rfilt object
        WindowLength    = @(sr) round(30*sr);  % In data samples
        WindowOverlap   = 50;           % In percentage
        WindowFunction  = @hamming;     % See help window
    end
    
    methods
        [y, varargout] = filter(obj, x, d, varargin);
    end
    
    % Constructor
    methods
        
        function obj = sliding_window_regr(varargin)
            
            import misc.process_arguments;
            
            if nargin < 1, return; end
            
            if isa(varargin{1}, 'filter.rfilt'),
                varargin = [{'Filter'}, varargin];
            end

            opt.Filter         = filter.mlag_regr;   % A filter.dfilt or filter.rfilt object
            opt.WindowLength   = @(sr) round(30*sr); % In data samples
            opt.WindowOverlap  = 50;                 % In percentage
            opt.WindowFunction = @hamming;
            opt.Name           = 'sliding_window_regr';
            opt.Verbose        = true;
            
            [~, opt] = process_arguments(opt, varargin);
            
            obj.Filter         = opt.Filter;
            obj.WindowLength   = opt.WindowLength;
            obj.WindowOverlap  = opt.WindowOverlap;
            obj.WindowFunction = opt.WindowFunction;
            
            obj = set_name(obj, opt.Name);
            obj = set_verbose(obj, opt.Verbose);
            
        end
        
        
    end
    
end