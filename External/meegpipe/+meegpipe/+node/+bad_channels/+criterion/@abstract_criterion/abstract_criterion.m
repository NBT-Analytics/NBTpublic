classdef abstract_criterion < ...
        meegpipe.node.bad_channels.criterion.criterion  & ...
        goo.abstract_configurable                       & ...
        goo.verbose                                     & ...
        goo.hashable                                    & ...
        goo.abstract_named_object                       & ...
        goo.reportable
    
    % hashable interface
    methods
        
        function hash = get_hash_code(obj)
            
            hash = get_hash_code(get_config(obj));
            
        end
        
    end
    
    % reportable interface
    methods
        
        function str = whatfor(~)
            
            str = '';
            
        end
        
        function [pName, pValue, pDescr]   = report_info(obj, varargin)
            
            [pName, pValue, pDescr]   = report_info(get_config(obj));
            
        end
        
        
    end   
    
    % Abstract constructor
    methods
        
        function obj = abstract_criterion(varargin)
       
            obj = obj@goo.abstract_configurable(varargin{:});
            
        end
        
    end
    
    
end