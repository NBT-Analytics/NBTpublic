classdef adaptfilt < ...
        filter.rfilt                & ...
        goo.verbose                 & ...
        goo.abstract_setget         & ...
        goo.abstract_named_object
    % ADAPTFILT - Adaptive filter
    %
    % Class filter.adaptfilt is a thing wrapper over MATLAB's class
    % adaptfilt [1], which is part of the DSP System Toolbox. This class can be
    % used to define a variaty of adaptive algorithms, such as Least Mean
    % Squares (LMS) and Recursive Least Squares (RLS).
    %
    % ## CONSTRUCTION
    %
    %   myFilter = filter.adaptfilt(filtObj);
    %   myFilter = filter.adaptfilt(filtObj, 'key', value, ...);
    %
    % Where
    %
    % MYFILTER is a filter.adaptfilt object
    %
    % FILTOBJ is an adaptfilt.* object
    %
    % 
    % ## KEY/VALUE PAIRS ACCEPTED BY CONSTRUCTOR
    %
    %   MinCorr: A natural scalar. Default: 0.25
    %       The minimum correlation between a regressor and a given data
    %       channel for the channel to be filtered. 
    %
    % 
    % ## USAGE EXAMPLES
    %
    % ### Example 1
    %
    % Regress out R from X using an LMS adaptive filter.
    %
    %   % Simulate a noise source
    %   N = 2*sin(2*pi*(1/500)*(1:10000));
    %   X = randn(1, size(N,2)) + N;
    %   % A simulated regressor that is correlated with the noise source
    %   R = 4*sin(2*pi*(1/500)*(1:10000)) + randn(1, size(N,2));
    %   % Filter out the regressor from X
    %   myFilter = filter.adaptfilt(adaptfilt.rls);
    %   Y = filter(myFilter, X, R);
    %
    %
    % ## REFERENCES
    %
    % [1] http://www.mathworks.nl/help/dsp/ref/adaptfilt.html
    %
    %
    % See also: adaptfilt
    
    properties (SetAccess = private, GetAccess = private)
        Filter;
        MinCorr = 0.25;
    end
    
    
    methods
        
        % consistency checks
        function obj = set.Filter(obj, value)
            import exceptions.InvalidPropValue;
            if isempty(value),
                throw(InvalidPropValue('Filter', 'Must be non-empty'));
            end
            
            if numel(value) ~= 1 || ...
                    isempty(regexp(class(value), '^adaptfilt.', 'once')),
                throw(InvalidPropValue('Filter', ...
                    'Must be an adaptfilt.* object'));
            end
            obj.Filter = value;
        end
        
        % filter.dfilt interface
        [y, obj] = filter(obj, x, d, varargin);
        
        function y = filtfilt(obj, varargin)
            y = filter(obj, varargin{:});
        end
        
        % Constructor
        function obj = adaptfilt(filtObj, varargin)
            
            import misc.process_arguments;
            
            if nargin < 1, return; end
            
            opt.Name = 'adaptfilt';
            opt.Verbose = true;
            opt.MinCorr = 0.25;
            [~, opt] = process_arguments(opt, varargin);
            
            obj.Filter = filtObj;
            obj.MinCorr = opt.MinCorr;
            
            obj = set_name(obj, class(obj.Filter));
            obj = set_verbose(obj, opt.Verbose);
            
        end
        
        
    end
    
    
end