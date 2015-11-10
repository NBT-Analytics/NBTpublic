classdef abstract_named_object < goo.named_object
    
    
    properties
        
        Name = '';
        
    end
    
    % Consistency checks
    methods
        
        function obj = set.Name(obj, name)
            import misc.isstring;
            
            if isempty(name),
                obj.Name = '';
                return;
            end
            
            if ~isstring(name),
                error('The Name property must be a string');
            end
            
            obj.Name = name;
            
        end
    end
    
    methods (Static, Access = protected)
        function obj = init_goo_abstract_named_object(obj, varargin)
            
            import misc.process_arguments;
            
            if nargin < 1, return; end
            
            opt.Name = '';
            [~, opt] = process_arguments(opt, varargin);
            
            obj.Name = opt.Name;
            
        end
    end
    
    % named_object interface
    methods
        
        function name = get_name(obj)
            
            import misc.strtrim;
            
          
            if isempty(obj.Name),
                name = class(obj);
            else
                name = strtrim(obj.Name);
            end
           
            name = regexprep(name, '[^\w\.]+', '-');
            
        end
        
        function name = get_full_name(obj)
            
            name = get_name(obj);
            
        end
        
        function obj = set_name(obj, name)
            
            obj.Name = name;
            
        end
        
    end
    
    % constructor
    methods
        
        function obj = abstract_named_object(varargin)
            
            if nargin < 1, return; end
            
            obj = goo.abstract_named_object.init_goo_abstract_named_object(obj, varargin{:});
            
        end
        
        
    end
    
end