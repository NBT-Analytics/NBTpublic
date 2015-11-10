classdef abstract_configurable < ...
        goo.configurable & ...
        goo.hashable & ...
        goo.reportable
    
  
    properties (GetAccess = private, SetAccess = private)
        
       Config; 
       
    end
  
    methods
        
        % goo.reportable interface
        function [pName, pVal, pDescr] = report_info(obj)
             
             % Provide info on built-in properties
             pName  = fieldnames(obj);
             pVal   = cell(numel(pName), 1);
             pDescr = repmat({''}, numel(pName), 1);
             for i = 1:numel(pName),
                 pVal{i} = obj.(pName{i});
             end
             
             % And concatenate it with config properties
             [pName2, pVal2, pDescr2] = report_info(obj.Config);
             pName  = [pName(:);pName2(:)];
             pVal   = [pVal(:);pVal2(:)];
             pDescr = [pDescr(:); pDescr2(:)];
            
        end
        
        function str = whatfor(obj)
            
            str = whatfor(obj.Config);
            
        end
        
        % goo.configurable interface
        obj     = set_config(obj, varargin);   
        val     = get_config(obj, varargin);         
        disp_body(obj);     
        obj = clone(obj);
        
        % default implementations defined here
        disp(obj);
        
    end
    
    % Default implementation of hashable interface
    methods
        
        function hashCode = get_hash_code(obj)
            
            import datahash.DataHash;
            
            if isempty(obj.Config),
                hashCode = DataHash([]);
            else
                hashCode = get_hash_code(obj.Config);
            end
            
        end
        
    end    
    
    % Virtual constructor
    methods
        function obj = abstract_configurable(varargin)
            
            import goo.get_cfg_class;
            
            if nargin == 1 && isa(varargin{1}, class(obj)),
                % Copy constructor -> clone the config           
                if ~isempty(varargin{1}.Config),
                    obj.Config  = clone(varargin{1}.Config);
                end
                return;
            end            
           
            cfgClass = get_cfg_class(obj);
            
            if isempty(cfgClass),
                obj.Config = goo.dummy_config;
            else
                obj.Config = eval(cfgClass);
            end
            
            obj = set_config(obj, varargin{:});         
            
        end
    end
    
end