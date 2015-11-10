classdef eeglab_fir < filter.abstract_dfilt
    % EEGLAB_FIR - Wrapper for EEGLAB's firws function
    %
    % The eeglab_fir class is a shallow wrapper around EEGLAB's ([1]) default
    % FIR filter implementation. Note that such a FIR implementation is (at the
    % time of this writing) far from optimal and it has been shown (see [2]) to
    % exhibit excessive filter ringing. Thus using this class to design filters
    % is not generally recommended. It is almost always better to use classes
    % filter.hpfilt, filter.lpfilt, and filter.bpfilt to build filters for
    % electrophysiological signals.
    %
    % ## CONSTRUCTION
    %
    %   myFilter = filter.eeglab_fir(fp);
    %   myFilter = filter.eeglab_fir(fp, 'key', value, ...);
    %   myFilter = filter.eeglab_fir('key', value, ...);
    %
    % Where
    %
    % MYFILTER is an eeglab_fir object
    %
    % FP is a 1x2 array with the edges of the pass band, in Hz. This
    % argument may also be provided as a key/value pair (see below).
    %
    %
    % ## KEY/VALUE PAIRS ACCEPTED BY CONSTRUCTOR
    %
    %   Fp:           A numeric 1x2 array
    %                 Edges of the frequency pass band (Hz).
    %
    %   Order:        A natural scalar. Default: []
    %                 FIR filter order. If left empty the order of the filter
    %                 will be guessed using EEGLAB's default filter order
    %                 heuristic.
    %
    %   Notch:        A boolean scalar. Default: false
    %                 If set to true, a notch filter instead of a pass band
    %                 filter will be produced.
    %
    %   SamplingRate: A natural scalar. Default: [], unspecified
    %                 If the data sampling rate is not specified, it will
    %                 be derived from property SamplingRate of the filter
    %                 input.
    %
    %   NbFrames:     Number of frames to filter per block. Default: 1000
    %                 See the documentation of EEGLAB's firfilt
    %
    %
    % ## USAGE EXAMPLES
    %
    % ### Example 1
    %
    % Apply a low pass filter with a cuttof at 20 Hz to data matrix X, assuming
    % a data sampling rate of 500 Hz.
    %
    %   % Generate a dummy dataset containing 4 channels and 20 seconds of data
    %   X = randn(4, 10000);
    %   myFilter = filter.eeglab_fir('Fp', [0 20]/(500/2));
    %   Y = filter(myFilter, X);
    %
    %
    % ## REFERENCES
    %
    % [1] EEGLAB: http://sccn.ucsd.edu/eeglab/
    %
    % [2] A. Widmann and E. Schroger, Filter Effects and Filter Artifacts
    % in the Analysis of Electrophysiological Data, Front. Psychol. 2012,
    % 3:233. DOI: http://dx.doi.org/10.3389%2Ffpsyg.2012.00233
    %
    %
    %
    % See also: filter.lpfilt, filter.hpfilt, filter.bpfilt
    
    properties
        
        Fp;
        Order;
        Notch;
        NbFrames;
        SamplingRate;
        
    end
    
    methods (Access = private)
        b = make_b(obj, data);
    end
    
    methods (Access = private, Static)
        boundaries = findboundaries(event);
        data = firfilt(data, b, nFrames, evBndry);
    end
    
    
    methods
        
        function obj = set.Order(obj, value)
            if ~isempty(value) && (value < 2 || mod(value, 2) ~= 0),
                error('Filter order must be a real, even, positive integer');
            end
            obj.Order = value;
        end
        
        % filter.dfilt interface
        function [data, obj] = filter(obj, data, varargin)
            import misc.eta;
            import physioset.event.class_selector;
            b = make_b(obj, data);
            v = is_verbose(obj);
            vL = get_verbose_label(obj);
            evBndry = get_event(data);
            if ~isempty(evBndry),
                mySel = class_selector('Class', 'discontinuity');
                evBndry = select(mySel, evBndry);
            end
            if v,
                fprintf([vL ...
                    'Filtering %dx%d data matrix with %s ...'], ...
                    size(data,1), size(data,2), class(obj));
                tinit = tic;
            end
            for i = 1:size(data,1)
                % Weird, but if we don't first get data(i,:) into x, the
                % following command generates a subasgn warning that is not
                % displayed but that screws up some of the tests. This
                % seems to be system specific.
                x = data(i,:);
                data(i,:) = filter.eeglab_fir.firfilt(x, b, obj.NbFrames, evBndry);
                if v,
                    misc.eta(tinit, size(data,1), i);
                end
            end
            if v,
                clear +misc/eta;
                fprintf('\n\n');
            end
        end
        
        function [y, obj] = filtfilt(obj, x, varargin)
            % Since this is a FIR filter, function filter already takes
            % care of shifting the filter output to the left according to the
            % the constant filter delay
            [y, obj] = filter(obj, x, varargin{:});
        end
        
        function obj = eeglab_fir(varargin)
            import misc.process_arguments;
            import misc.set_properties;
           
            obj = obj@filter.abstract_dfilt(varargin{:});
            
            warning('eeglab_fir:SubOptimal', ...
                ['eeglab_fir filters may be sub-optimal. Filters ' ...
                'filter.hpfilt, filter.lpfilt, filter.bpfilt are generally ' ...
                'better for electrophysiological signals']);
            
            if nargin < 1, return; end
            
            if isnumeric(varargin{1}),
                varargin = [{'Fp'}, varargin];
            end
            
            opt.Fp    = [];
            opt.Order = [];
            opt.Notch = false;
            opt.NbFrames = 1000;
            opt.SamplingRate = [];
            [~, opt] = process_arguments(opt, varargin);
            
            if isempty(opt.Fp),
                error('Argument Fp needs to be provided');
            end
            
            obj = set_properties(obj, opt);
            
        end
        
        
        
    end
    
    
    
    
    
end