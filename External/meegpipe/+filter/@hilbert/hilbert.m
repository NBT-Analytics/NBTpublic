classdef hilbert < ...
        filter.dfilt             & ... 
        goo.verbose              & ... 
        goo.abstract_setget      & ... 
        goo.abstract_named_object
    % thilbert - Filter using Hilbert transform
    %
    % 
    %
    % See also: filter
    
    properties (SetAccess = private, GetAccess = private)
        
        Operator = @(x) abs(x);
        
    end
    
    % consistency checks
    methods
        % to be done
        
    end
    
    % filter.dfilt interface
    methods
        [y, obj] = filter(obj, x, d, varargin);
        y = filtfilt(obj, x, varargin);
    end
    
    
    % Constructor
    methods
        
        function obj = hilbert(varargin)
            
            import misc.process_arguments;
         
            opt.Name = 'hilbert';
            opt.Verbose = true;  
            opt.Operator = @(x) abs(x);

            [~, opt] = process_arguments(opt, varargin);         
           
            obj = set_name(obj, opt.Name);
            obj = set_verbose(obj, opt.Verbose);
            
            obj.Operator = opt.Operator;
            
        end
        
        
    end
    
    
end