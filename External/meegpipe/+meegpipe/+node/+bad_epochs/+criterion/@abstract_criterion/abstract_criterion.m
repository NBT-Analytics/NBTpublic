classdef abstract_criterion < ...
        meegpipe.node.bad_epochs.criterion.criterion & ...
        goo.abstract_configurable & ...
        goo.verbose & ...
        goo.hashable & ...
        goo.abstract_named_object & ...
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
        
        function [pName, pValue, pDescr] = report_info(obj, varargin)
            
            [pName, pValue, pDescr] = report_info(get_config(obj));
            
        end
        
        
    end
   
    % Abstract constructor
    methods
        
        function obj = abstract_criterion(varargin)            
          
            import misc.split_arguments;
            
            % set some special properties: so far only Config
            % The values of this properties will be "cloned"
            [thisArgs, configArgs] = ...
                split_arguments({'Config'}, varargin); 
            if ~isempty(thisArgs),
                opt = cell2struct(thisArgs(2:2:end), thisArgs(1:2:end), 2);
                fNames = fieldnames(opt);
                for i = 1:numel(fNames)
                    obj.(fNames{i}) = clone(opt.(fNames{i}));
                end
            end
            
            % set configuration options            
            obj = set_config(obj, configArgs{:});      
            
        end
        
    end
    
    
end