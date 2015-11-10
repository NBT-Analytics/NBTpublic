classdef abstract_setget < ...
        goo.setget      & ...
        goo.hashable    & ...
        goo.reportable
    % ABSTRACT_SETGET - Simple implementation of the setget interface
    %
    % See also: goo.setget
    
  
    properties (GetAccess = private, SetAccess = private)
        
        Info = struct;
        
    end
  
    % Must be sealed in order to allow for object arrays
    methods (Sealed)
        
        obj     = set(obj, varargin);
        value   = get(obj, varargin);
        value   = get_meta(obj, varargin);
        obj     = set_meta(obj, varargin);
        
    end
    
    methods
        
        % goo.reportable interface
        function [pName, pVal, pDescr] = report_info(cfg)
            
            pName  = fieldnames(cfg);
            pVal   = cell(numel(pName), 1);
            pDescr = repmat({''}, numel(pName), 1);
            for i = 1:numel(pName),
                pVal{i} = cfg.(pName{i});
            end
            
            
        end
        
        function str = whatfor(~)
            
            str = '';
            
        end
        
        % hashable interface
        hash = get_hash_code(obj);
        
        % setget interface
        disp_meta(obj);
        
        [getNames, setNames, allNames] = fieldnames(x)
        
        y = struct(x);
        
        function obj = unset_meta(obj, varargin)
            
            for i = 1:numel(varargin),
                
                if ~isfield(obj.Info, varargin{i}), continue; end
                obj.Info = rmfield(obj.Info, varargin{i});
                
            end
            
        end
        
        function props = meta_props(obj)
            
            props = fieldnames(obj(1).Info);
            
        end
        
        % Default implementations of methods declared here
        disp(obj, varargin);
        
    end
    
    % Abstract constructor
    methods
        
        function obj = abstract_setget(varargin)
            
            if nargin < 1, return; end
            
            if nargin == 1 && isa(varargin{1}, class(obj)),
                obj = varargin{1};
                return;
            end
            
            obj = set(obj, varargin{:});
            
            
        end
        
    end
    
    
end