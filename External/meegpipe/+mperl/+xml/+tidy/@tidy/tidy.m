classdef tidy
    
    properties 
       Filename; 
    end
    
    methods
        [status, msg] = make_tidy(obj, varargin);        
    end
    
    methods
        function obj = tidy(filename)
           import mperl.file.spec.rel2abs;
            
           obj.Filename = rel2abs(filename);
           
        end
    end
    
    
    
end