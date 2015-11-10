classdef cca < ...
        filter.dfilt                & ...
        goo.verbose                 & ...
        goo.abstract_setget         & ...
        goo.abstract_named_object
    % CCA - Spatial CCA filtering
    
    
    properties

        CCA = spt.bss.cca;
        % To be applied to the selected canonical components
        CCFilter = []; 
        
    end
    
    
    methods
        % filter.dfilt interface
        [y, obj] = filter(obj, x, varargin);
        
        function [y, obj] = filtfilt(obj, x, varargin)
            
            [y, obj] = filter(obj, x, varargin{:});
            
        end
        
        % Redefinitions of methods from goo.verbose
        function obj = set_verbose(obj, bool)
            obj = set_verbose@goo.verbose(obj, bool);
            if ~isempty(obj.CCFilter),
                obj.CCFilter = set_verbose(obj.CCFilter, bool);
            end
        end
       
    end
  
    % Constructor
    methods
        
        function obj = cca(varargin)
            
            import misc.process_arguments;
       
            opt.CCA = spt.bss.cca;
            opt.CCFilter = [];
            opt.Name     = 'filter.cca';
            opt.Verbose  = true;
            
            [~, opt] = process_arguments(opt, varargin, [], true);
            
            obj.CCA = opt.CCA;
            obj.CCFilter = opt.CCFilter;
            
            obj = set_name(obj, opt.Name);
            obj = set_verbose(obj, opt.Verbose);
            
        end
        
        
    end   
    
   
end