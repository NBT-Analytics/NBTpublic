classdef sbfilt < filter.abstract_dfilt
    % SBFILT - Class for stop-band digital filters
    %
    % obj = spfilt('key', value, ...)
    %
    %
    % where
    %
    % OBJ is an bpfilt object
    %
    %
    % ## Most common key/value pairs:
    %
    % ## Most common key/value pairs:
    %
    %       Fstop: A numeric 2x1 array.
    %           Normalized 6dB cutoff frequencies of the stopband(s). For
    %           instance, Fp=[0.25 0.50] will use a stopband delimited
    %           by the frequencies 0.25*fs/2 and 0.50*fs/2 with fs the
    %           sampling frequency.
    %
    %       PersistentMemory:  A logical scalar. Default: false
    %           Determines whether to save the filter state. If set to true
    %           the filter state will be saved, which is useful when 
    %           processing large datasets in data chunks. Note however that
    %           using persistent memory will slow-down considerably the 
    %           filtering operation.
    %
    %
    % ## Notes:
    %
    % * Saving the filter state is useful when the filter is to be applied
    %   by segmenting the data into various epochs and calling the method
    %   filter() on each of those epochs separately. However, saving the
    %   filter state will slow down considerably the filtering operation.
    %
    % * Multiple stopbands can be specified like this:
    %   obj = bpfilt('fp', [0.1 0.2;0.3 0.4])
    %   which will create a stopband filter with stop bands [0.1 0.2] and
    %   [0.3 0.4]
    %
    %
    % See also: bpfilt, lpfilt, hpfilt
    
    properties (SetAccess = private, GetAccess = private)
       MDFilt; 
    end
    
   
    properties (SetAccess = 'private')
        LpFilter;
        HpFilter;
        FStop;
    end
    
    % misc.verbose interface reimplementation
    methods
        obj = set_verbose(obj, verbose);
        obj = set_verbose_label(obj, verboselabel);        
    end    
        
    % filter.dfilt interface
    methods
        [y, obj] = filter(obj, x, varargin);
    end
    
    % report.self_reportable interface
    methods         
        [pName, pValue, pDescr]   = report_info(obj);
        % The method below is implemented at abstract_dfilt
        % filename = generate_remark_report(obj, varargin);
    end
    
    
    % Own methods (implemented and defined here)
    methods
        y = filtfilt(obj, x, varargin);
        % required by abstract_dfilt
        H = mdfilt(obj);
    end   
    
    methods
        function obj = sbfilt(varargin)
            import misc.process_arguments;
            
            obj = obj@filter.abstract_dfilt(varargin{:});
            
            opt.fstop               = [];
            opt.verboselabel        = '(filter.sbfilt)';
            opt.verbose             = true;
            opt.persistentmemory    = false;
            
            [~, opt] = process_arguments(opt, varargin);
            
            if ~isempty(opt.fstop),
                obj.LpFilter = cell(1, size(opt.fstop,1));
                obj.HpFilter = cell(1, size(opt.fstop,1));
                for filtItr = 1:size(opt.fstop),
                    if opt.fstop(filtItr, 2) < 1,
                        obj.HpFilter{filtItr} = ...
                            filter.hpfilt('fc', opt.fstop(filtItr, 2));
                    end
                    if opt.fstop(filtItr, 1) > 0,
                        obj.LpFilter{filtItr} = ...
                            filter.lpfilt('fc', opt.fstop(filtItr, 1));
                    end
                end
            end
            obj.FStop = opt.fstop;
            
            obj = set_verbose(obj, opt.verbose);
            obj = set_verbose_label(obj, opt.verboselabel);
            
        end
        
    end
    
    
end