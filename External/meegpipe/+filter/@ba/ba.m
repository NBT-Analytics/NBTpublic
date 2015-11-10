classdef ba < ...
        filter.dfilt             & ...
        goo.verbose              & ...
        goo.abstract_setget      & ...
        goo.abstract_named_object
    % BA - A generic digital filter built from B and A coefficients
    %
    % This class implements a generic digital filter as defined by a set of
    % B and A coefficients. Typically, users will not want to use this
    % class directly but they will prefer to use any of the other digital
    % filter classes that are built on top of filter.ba: filter.lpfilt and
    % filter hpfilt.
    %
    % ## CONSTRUCTION
    %
    %   myFilter = filter.ba(b, a)
    %
    % Where
    %
    % MYFILTER is a filter.ba object
    %
    % B and A are the filter coefficients
    %
    %
    % ## USAGE EXAMPLES
    %
    % ### Example 1
    % 
    % Apply a moving average filter of order 20 to data matrix X:
    %
    %   X = randn(4, 10000);
    %   myFilter = filter.ba(ones(1, 20), 1);
    %   Y = filter(myFilter, X);
    %
    %
    %
    % See also: filter.lpfilt, filter.hpfilt, filter.bpfilt, filter.sbfilt
    
    properties (SetAccess = private, GetAccess = public)
        B;
        A;
    end
    
    methods
        % filter.dfilt interface
        [y, obj] = filter(obj, x, d, varargin);
        y = filtfilt(obj, x, varargin);
        
        % In order to be used in combination with filter.cascade
        function H = mdfilt(obj)
            H = dfilt.df1(obj.B, obj.A);
        end
        
        
        % Constructor    
        function obj = ba(b, a, varargin)
            
            import misc.process_arguments;
            
            if nargin < 1, return; end
            
            opt.Name = 'ba';
            opt.Verbose = true;
            [~, opt] = process_arguments(opt, varargin);
            
            obj.A = a;
            obj.B = b;
            obj = set_name(obj, opt.Name);
            obj = set_verbose(obj, opt.Verbose);
            
        end
        
        
    end
    
    
end