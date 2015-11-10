classdef hpfilt < filter.abstract_dfilt
    % HPFILT - High-pass digital filter (windowed sinc type I FIR)
    %
    % This class implements the recommended approach for high-pass
    % filtering electrophysiological time-series [1]. It is implemented in terms
    % of a windowed sinc type I linear phase FIR filter. The implementation
    % has been borrowed from Andreas Widmann's firfilt plug-in for EEGLAB
    % [2].
    %
    % ## CONSTRUCTION
    %
    %   myFilter = filter.hpfilt(fc);
    %   myFilter = filter.hpfilt(fc, 'key', value, ...);
    %   myFilter = filter.hpfilt('key', value, ...);
    %
    % Where
    %
    %   MYFILTER is a filter.hpfilt object.
    %
    %   FC is the normalized cutoff frequency of the filter. This construction
    %   argument can also be provided as a key/value pair (see below).
    %
    %
    % ## KEY/VALUE PAIRS ACCEPTED BY CONSTRUCTOR
    %
    %   Fc : A numeric scalar. Default: []
    %        The normalized cutoff frequency of the filter.
    %
    %   TransitionBandWidth : A numeric scalar. Default: 0.25*Fc
    %        The (normalized) bandwidth of the transition band. This
    %        parameter is inversely proportional to the filter order. So
    %        you should try to use as wide transition band as is acceptable
    %        for your application.
    %
    %   MaxOrder : A numeric scalar. Default: 10000
    %       The maximum allowed order for the filter. Note that this
    %       parameter imposes a lower limit on the width of the transition
    %       band.
    %
    %
    % ## USAGE EXAMPLES
    %
    % ### Example 1
    %
    % Apply a high pass filter with a cuttof at 2 Hz to data matrix X, assuming
    % a data sampling rate of 500 Hz.
    %
    %   % Generate a dummy dataset containing 4 channels and 20 seconds of data
    %   X = randn(4, 10000);
    %   myFilter = filter.hpfilt(2/(500/2));
    %   Y = filter(myFilter, X);
    %
    % ## REFERENCES
    %
    % [1] A. Widmann and E. Schroger, Filter Effects and Filter Artifacts
    % in the Analysis of Electrophysiological Data, Front. Psychol. 2012,
    % 3:233. DOI: http://dx.doi.org/10.3389%2Ffpsyg.2012.00233
    %
    % [2] http://www.uni-leipzig.de/~biocog/content/widmann/eeglab-plugins/
    %
    %
    % See also: filter.lpfilt, filter.bpfilt, filter.sbfilt
    
    properties (SetAccess=private)
        Order;
        TransitionBandWidth;   % Normalized!
    end
    
    properties (SetAccess = private)
        BAFilter;
    end
    
    methods
        
        function [y, obj] = filter(obj, varargin)
            [y, obj] = filter(obj.BAFilter, varargin{:});
        end
        
        function y = filtfilt(obj, varargin)
            if numel(obj.BAFilter.A) > 1,
                y = filtfilt(obj.BAFilter, varargin{:});
            else
                % Since this is a FIR filter, filtfilt() is not necessary
                % to ensure zero filter delay and a linear phase response.
                y = filter(obj.BAFilter, varargin{:});
            end
        end
        
        function H = mdfilt(obj)
            H = mdfilt(obj.BAFilter);
        end
        
        % Constructor
        function obj = hpfilt(varargin)
            import misc.process_arguments;
            import filter.abstract_dfilt;
            
            obj = obj@filter.abstract_dfilt(varargin{:});
            
            if nargin < 1, return; end
            
            if isnumeric(varargin{1}),
                varargin = [{'fc'}, varargin];
            end
            
            opt.fc = [];
            opt.transitionbandwidth = [];
            opt.maxorder = 10*1000;
            [~, opt] = process_arguments(opt, varargin);
            
            if isempty(opt.fc),
                error('The (normalized) cutoff frequency fc needs to be provided');
            end
            
            if isempty(opt.transitionbandwidth),
                opt.transitionbandwidth = 0.25*opt.fc;
            end
            
            order = firfilt.firwsord('hamming', 1, opt.transitionbandwidth);
            
            if order > opt.maxorder,
                warning(...
                ['The minimum filter order that meets the specifications ' ...
                '(%d) exceeds the maximum allowed filter order (%d). The ' ...
                'generated filter will not meet the specs exactly! You may ' ...
                'want to increase the maximum allowed filter order.'], ...
                order, opt.maxorder);
            end
            obj.Order = min(order, opt.maxorder);
            
            B = firfilt.firws(obj.Order, opt.fc, 'high', ...
                firfilt.windows('hamming', obj.Order + 1));
            obj.BAFilter = filter.ba(B, 1);
            
            obj.BAFilter = set_name(obj.BAFilter, get_name(obj));
            obj.BAFilter = set_verbose(obj.BAFilter, is_verbose(obj));
            
        end
        
    end
    
end