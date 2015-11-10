classdef fieldtrip_butter < filter.abstract_dfilt
    % FIELDTRIP_BUTTER - High-pass digital filter
    %
    % The fieldtrip_butter class implements a Fieldtrip-like Butterworth
    % IIR filter. This is the default filter used by Fieldtrip functions
    % ft_preproc_[band/high/low]passbandfilter. A stable Butterworth
    % filter cannot be always produced, especially when designing high pass
    % filters with extreme cutoff frequencies (0.2 Hz and below). In such
    % cases, fieldtrip_butter will produce a stable filter by simply
    % reducing the order of the filter, which may lead to a filter with an
    % effective cuttoff considerably different from the desired cutoff. 
    % 
    % This class is provided mostly for users that want the filtering results to
    % be comparable with those obtained with Fieldtrip. Otherwise, it is almost
    % always better to use class filter.bpfilt to design filters for
    % electrophysiological time-series. 
    %
    %
    % ## CONSTRUCTION
    %
    %   myFilter = filter.fieldtrip_butter(fp);
    %   myFilter = filter.fieldtrip_butter('key', value, ...);
    %
    %
    % Where
    %
    % OBJ is a filter.hpfilt object
    %
    % FP is a 1x2 array with the edges of the pass band, in normalized 
    % frequencies. Note that FP can also be provided as a key/value pair (see
    % below).
    %
    %
    % ## KEY/VALUE PAIRS ACCEPTED BY CONSTRUCTOR
    %
    %   Fp:           A numeric 1x2 array
    %                 Edges of the frequency pass band in normalized frequencies.
    %               
    %   Fs:           A numeric 1x2 array
    %                 Edges of the frequency stop band in normalized frequencies.
    %                 Only relevant for stop-band filters. Note that you cannot
    %                 especify both Fp and Fs. 
    %
    %
    %
    % ## USAGE EXAMPLES
    %
    % ### Example 1
    %
    % Apply a low pass filter with a cutoff at 20 Hz to data matrix X,
    % assuming a data sampling rate of 500 Hz
    %
    %   % Generate a dummy dataset containing 4 channels and 20 seconds of data
    %   X = randn(4, 10000);
    %   myFilter = filter.fieldtrip_butter('Fp', [0 20]/(500/2));
    %   Y = filter(myFilter, X);
    %
    %
    % ## REFERENCES
    %
    % [1] Fieldtrip: http://fieldtrip.fcdonders.nl/
    %
    %
    % See also: filter.bpfilt, filter.lpfilt, filter.hpfilt
    
    properties (SetAccess=private)
        Order;
    end
    
    properties (SetAccess = private)
        BAFilter;
        Fp;
    end
    
    methods (Static)
        [B, A] = get_coefficients(order, fp); 
    end
    
    methods
        
        function [y, obj] = filter(obj, varargin)
            [y, obj] = filter(obj.BAFilter, varargin{:});
        end
        
        function y = filtfilt(obj, varargin)
            y = filtfilt(obj.BAFilter, varargin{:});
        end
        
        function H = mdfilt(obj)
            H = mdfilt(obj.BAFilter);
        end
        
        % Constructor
        function obj = fieldtrip_butter(varargin)
            import misc.process_arguments;
            import filter.abstract_dfilt;
            import filter.fieldtrip_butter;
            
            obj = obj@filter.abstract_dfilt(varargin{:});
            
            if nargin < 1, return; end
            
            if isnumeric(varargin{1}),
                varargin = [{'Fp'}, varargin];
            end
        
            opt.Fp = [];
            opt.Fs = [];
            [~, opt] = process_arguments(opt, varargin);
            
            if isempty(opt.Fp) && isempty(opt.Fs),
                error('Either Fp or Fs need to be specified');
            end
            if ~isempty(opt.Fp) && ~isempty(opt.Fs),
                error('You cannot specify both Fs and Fp');
            end
            
            if ~isempty(opt.Fs),
                % A stopband filter
                wn = -opt.Fs;
            else
                wn = opt.Fp;
            end
            
            filterOrder = 6;
            [B, A] = fieldtrip_butter.get_coefficients(filterOrder, wn);
            
            while any(abs(roots(A)) >= 1) && filterOrder > 2,
                filterOrder = filterOrder - 1;
                [B, A] = fieldtrip_butter.get_coefficients(filterOrder, wn);
                warning('fieldtrip_butter:Unstable', ...
                    'Filter is unstable, reducing filter order to %d', ...
                    filterOrder);
            end
            if any(abs(roots(A)) >= 1)
                error(['Filter coefficients have poles on or outside ' ...
                    'the unit circle and will not be stable. Try a higher cutoff ' ...
                    'frequency or a different type/order of filter.']);
            end
            obj.Order = filterOrder;
            obj.Fp    = opt.Fp;
            obj.BAFilter = filter.ba(B, A);
            
            obj.BAFilter = set_name(obj.BAFilter, get_name(obj));
            obj.BAFilter = set_verbose(obj.BAFilter, is_verbose(obj));
         
        end
        
    end
    
end