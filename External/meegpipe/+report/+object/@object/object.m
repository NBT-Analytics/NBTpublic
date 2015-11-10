classdef object < report.generic.generic
    
    
    
    %% IMPLEMENTATION .....................................................
    
    properties
        Objects;
    end
    
    methods (Access = private)
        
        [pValue, refs] = pval2str(obj, pValue, varargin);
        
        [pValue, refs] = sreportable2str(obj, pValue, varargin);
        
        [pValue, refs] = reportable2str(obj, pValue, varargin);
        
        [pValue, refs] = num2str(obj, pValue, varargin);
        
        [pValue, refs] = struct2str(obj, pValue, varargin)
        
    end
    
    %% PROTECTED INTERFACE ................................................
    
    % redefinitions of parent class methods
    methods (Access = protected)
       
        % default name of the associated remark file
        fName       = def_filename(obj);
        
    end
    
    
    %% PUBLIC INTERFACE ...................................................
    methods
        generate(obj, varargin);
        disp_body(obj);
    end
    
    
    % Constructor
    methods
        
        function obj = object(varargin)
            import goo.pkgisa;
            
            count = 0;
            while (count < numel(varargin)) && ~ischar(varargin{count+1}),
                count = count + 1;
            end
            
            obj = obj@report.generic.generic(varargin{count+1:end});
            
                
            obj.Objects = varargin(1:count);
            
            if isempty(get_title(obj)),
                if nargin == 1 && ...
                        pkgisa(varargin{1}, ...
                        {'goo.named_object', 'goo.named_object_handle'})
                    set_title(obj, get_full_name(varargin{1}));
                else
                    set_title(obj, 'Object report');
                end
            end
            
        end
    end
    
    
    
end