classdef abstract_dfilt < ...
        filter.dfilt             & ...
        goo.verbose              & ...
        goo.abstract_setget      & ...
        goo.printable            & ...
        goo.abstract_named_object
    % ABSTRACT_DFILT - Common ancestor to digital filter classes
    
    methods (Static, Access = protected)  
        [y, wp, ws, rp, rs] = filt_ord(designmethod, wp, ws, rp, rs, type)
    end

    methods
        
        % Conversion to a MATLAB dfilt.?? object
        function H =  mdfilt(obj) %#ok<STOUT>
            error('Class %s does not implement method mdfilt', class(obj));
        end
    end
    
    methods     
        y = filtfilt(obj, x, varargin); 
    end

    % report.printable interface
    methods
        count = fprintf(fid, obj, varargin);
    end
    
    
    % Virtual constructor
    methods
        function obj = abstract_dfilt(varargin)
            import misc.process_arguments;
            import misc.split_arguments;
            
            opt.Verbose = true;
            opt.VerboseLabel = @(x, meth) sprintf('(%s:%s) ', class(x), meth);
            [thisArgs, varargin] = split_arguments(opt, varargin);
            [~, opt] = process_arguments(opt, thisArgs);
            
            obj = obj@goo.abstract_named_object(varargin{:});
           
            if ~isempty(opt.Verbose),
                obj = set_verbose(obj, opt.Verbose);
            end
            
            if ~isempty(opt.VerboseLabel),
                obj = set_verbose_label(obj, opt.VerboseLabel);
            end
                
            
        end
        
    end
    
    
end