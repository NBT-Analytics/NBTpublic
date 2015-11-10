classdef bpfilt < filter.abstract_dfilt
    % BPFILT - Band-pass digital filter (windowed sinc type I FIR)
    %
    % This class implements the recommended approach for band-pass
    % filtering electrophysiological time-series [1]. It is implemented in terms
    % of a windowed sinc type I linear phase FIR filter. The implementation
    % has been borrowed from Andreas Widmann's firfilt plug-in for EEGLAB
    % [2].
    %
    % ## CONSTRUCTION
    % 
    %   myFilter = filter.bpfilt(fp);
    %   myFilter = filter.bpfilt(fp, 'key', value, ...);
    %   myFilter = filter.bpfilt('key', value, ...);
    %
    %
    % Where
    %
    % MYFILTER is a filter.bpfilt object
    %
    % FP is a Kx2 matrix with the edges of K passbands.
    %
    %
    % ## Most common key/value pairs:
    %
    %   Fp: A numeric Kx2 array. Default: []
    %       Normalized 6dB cutoff frequencies of the passband. For instance, 
    %       Fp=[0.25 0.50] will use a passband delimited by the frequencies
    %       0.25*fs/2 and 0.50*fs/2 with fs the sampling rate. You can
    %       especify multiple passbands (one per row of Fp).
    %
    %   TransitionBandWidth : A numeric scalar. 
    %       Default: [], i.e. use the defaults for classes lpfilt and hpfilt
    %        The (normalized) bandwidth of the transition band. This
    %        parameter is inversely proportional to the filter order. So
    %        you should try to use as wide transition band as is acceptable
    %        for your application.
    %
    %   MaxOrder : A numeric scalar. Default: 30000
    %       The maximum allowed order for the filter. Note that this
    %       parameter imposes a lower limit on the width of the transition
    %       band. 
    %
    %
    % ## Notes:
    %
    % * Multiple passbands can be specified like this:
    %
    %   obj = bpfilt('fp', [0.1 0.2;0.3 0.4])
    %
    %   which will create a passband filter with pass bands [0.1 0.2] and
    %   [0.3 0.4]
    %
    %
    %
    % See also: lpfilt, hpfilt, sbfilt
    
    properties (SetAccess = private, GetAccess = private)
        MDFilt;     % Equivalent MATLAB dfilt object
    end
    
    properties (SetAccess = private)
        LpFilter;
        HpFilter;
        Fp;
    end
    
    % filter.dfilt interface
    methods
        function [y, obj] = filter(obj, varargin)
            y = filtfilt(obj, varargin{:});
        end
        
        % Reimplement the set_verbose method from class goo.verbose
        function obj = set_verbose(obj, value)
            
            obj = set_verbose@goo.verbose(obj, value);
            
            if value, return; end
            
            % This should be done only when setting verbose to false: we
            % dont want the nested filters to produce any output
            for i = 1:numel(obj.LpFilter),
                if isempty(obj.LpFilter{i}), continue; end
                obj.LpFilter{i} = set_verbose(obj.LpFilter{i}, value);
            end
            
            for i = 1:numel(obj.HpFilter),
                if isempty(obj.HpFilter{i}), continue; end
                obj.HpFilter{i} = set_verbose(obj.HpFilter{i}, value);
            end
            
        end
     
        y = filtfilt(obj, x, varargin);
        
        % Required by parent class
        H = mdfilt(obj);
        
        % Constructor 
        function obj = bpfilt(varargin)
            import misc.process_arguments;
            
            obj = obj@filter.abstract_dfilt(varargin{:});
            
            if nargin < 1, return; end
            
            if isnumeric(varargin{1}),
                varargin = [{'fp'}, varargin];
            end
            
            opt.fp                  = [];
            opt.transitionbandwidth = [];
            opt.maxorder            = [];
            opt.verbose             = true;
            opt.verboselabel        = '(filter.bpfilt) ';
            
            [~, opt] = process_arguments(opt, varargin);
            
            if ~isempty(opt.fp),
                obj.LpFilter = cell(1, size(opt.fp,1));
                obj.HpFilter = cell(1, size(opt.fp,1));
                for filtItr = 1:size(opt.fp,1),
                    if opt.fp(filtItr, 2) < 1,
                        obj.LpFilter{filtItr} = ...
                            filter.lpfilt(...
                            'fc',                  opt.fp(filtItr, 2), ...
                            'TransitionBandWidth', opt.transitionbandwidth, ...
                            'MaxOrder',            opt.maxorder, ...
                            'Verbose',             opt.verbose, ...
                            'VerboseLabel',        opt.verboselabel);
                    end
                    if opt.fp(filtItr, 1) > 0,
                        obj.HpFilter{filtItr} = ...
                            filter.hpfilt(...
                            'fc',                  opt.fp(filtItr, 1), ...
                            'TransitionBandWidth', opt.transitionbandwidth, ...
                            'MaxOrder',            opt.maxorder, ...
                            'Verbose',             opt.verbose, ...
                            'VerboseLabel',        opt.verboselabel);
                    end
                end
            end
            obj.Fp = opt.fp;
            
            % Now set the verbose property, but not for nested filters
            obj = set_verbose(obj, opt.verbose);
            obj = set_verbose_label(obj, opt.verboselabel);
        end
        
    end
    
    
end