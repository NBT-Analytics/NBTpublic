classdef ellip < filter.abstract_dfilt
    % ELLIP - Digital filter using elliptic filter design
    %
    % Class filter.ellip designs lowpass, bandpass, highpass, and bandstop
    % digital filters. Elliptic filters offer steeper rolloff characteristics
    % than Butterworth or Chebyshev filters, but are equiripple in both the
    % pass- and stopbands. In general, elliptic filters meet given performance
    % specifications with the lowest order of any filter type.
    %
    % In general, it is recommended to use classes filter.lpfilt,
    % filter.hpfilt, filter.bpfilt and filter.sbfilt to design filters for
    % electrophysiological time-series. However, those classes produce FIR
    % filters of orders considerably greater than the elliptic filtes
    % produced by this class, for the same filter specifications. Thus,
    % when your signals are very short you may not be able to use a FIR
    % filter as the filter may be too long.
    %
    % WARNING: Be aware that, due to the steep rolloff characteristics of
    % elliptic filters, they may lead to considerable filter artifacts in
    % the time domain, especially when designing high-pass filters with
    % extreme cutoff frequencies (0.1 Hz and below). 
    %
    % 
    % ## CONSTRUCTION
    % 
    %   myFilter  = filter.ellip(fc);
    %   myFilter  = filter.ellip('key', value, ...);
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
    %   Fp:             A numeric 1x2 array. Default: []
    %                   Edges of the frequency pass band in normalized frequencies.
    %               
    %   Fs:             A numeric 1x2 array. Default: []
    %                   Edges of the frequency stop band in normalized frequencies.
    %                   Only relevant for stop-band filters. Note that you cannot
    %                   especify both Fp and Fs. NOTE: Stopband filters have
    %                   not been implemented yet!
    %
    %   StopBandAttn:   A numeric scalar. Default: 45
    %                   Stopband attenuation in dBs
    %
    %   PassBandRipple: A numeric scalar. Default: 0.1
    %                   Passband gain ripple in dBs
    %
    %   MaxOrder:       A natural scalar. Default: 100
    %                   The maximum allowed order for the filter. If the
    %                   requested specifications cannot be met with a filter
    %                   of an order equal or smaller to MaxOrder, a filter of
    %                   order MaxOrder will be produced anyways. A warning
    %                   will be displayed in such case indicating the actual
    %                   specifications of the filter.
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
    %   myFilter = filter.ellip('Fp', [0 20]/(500/2));
    %   Y = filter(myFilter, X);
    %
    %
    % ## REFERENCES
    %
    % [1] http://www.mathworks.nl/help/signal/ref/ellip.html
    %
    %
    % See also: filter.bpfilt, filter.lpfilt, filter.hpfilt
    
    properties (SetAccess=private)
        Order;
        Delay;
        Specs;
        H;
    end
    
    methods (Static)
        [H, specs, order, delay] = design_filter(wn, rp, rs, maxOrder);
    end
    
    methods
        
        % filter.dfilt interface
        [y, obj] = filter(obj, varargin)
        y = filtfilt(obj, varargin)
        
        % from abstract_dfilt
        function H = mdfilt(obj)
            H = obj.H;
        end
        
        % Constructor
        function obj = ellip(varargin)
            import misc.process_arguments;
            import filter.abstract_dfilt;
            
            obj = obj@filter.abstract_dfilt(varargin{:});
            
            if nargin < 1, return; end
            
            if isnumeric(varargin{1}),
                varargin = [{'Fp'}, varargin];
            end
            
            opt.Fp = [];
            opt.Fs = [];
            opt.MaxOrder = 30;
            opt.StopBandAttn = 45;
            opt.PassBandRipple = 0.1;
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
           
            [obj.H, obj.Specs, obj.Order, obj.Delay] = ...
                filter.ellip.design_filter(wn, ...
                opt.PassBandRipple, ...
                opt.StopBandAttn, ...
                opt.MaxOrder);

        end
        
    end
    
end