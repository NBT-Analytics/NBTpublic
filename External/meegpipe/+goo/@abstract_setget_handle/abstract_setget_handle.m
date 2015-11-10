classdef abstract_setget_handle < ...
        goo.setget_handle & ...
        goo.clonable & ...
        goo.reportable_handle
    % ABSTRACT_SETGET - Simple implementation of the setget interface
    %
    % See also: goo.setget

    properties (GetAccess = private, SetAccess = private)
        
        Info = struct;
        
    end

    % setget interface
    methods (Sealed)
        
        obj     = set(obj, varargin);
        value   = get(obj, varargin);
        value   = get_meta(obj, varargin);
        obj     = set_meta(obj, varargin);
        newObj  = clone(obj);
        
    end
    
    methods
        
        % goo.reportable_handle interface
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
        
        [get_names, set_names, all_names] = fieldnames(x)
        
        y = struct(x);
        
        function obj = unset_meta(obj, varargin)
            
            for i = 1:numel(varargin),
                
                if ~isfield(obj.Info, varargin{i}), continue; end
                obj.Info = rmfield(obj.Info, varargin{i});
                
            end
            
        end
        
        function props = meta_props(obj)
            
            props = fieldnames(obj.Info);
            
        end
        
        % Default implementations of methods declared here
        disp(obj, varargin);
        
    end
    
    % Abstract constructor
    methods
        
        function obj = abstract_setget_handle(varargin)
            
            if nargin < 1, return; end
            
            if nargin == 1 && isa(varargin{1}, class(obj)),
                % Copy constructor
                
                fNames = fieldnames(varargin{1});
                for i = 1:numel(fNames)
                    val = get(varargin{1}, fNames{i});
                    
                    obj.(fNames{i}) = goo.clone(val);
                end
                
                return;
                
            end
            
            obj = set(obj, varargin{:});
          
        end
        
    end
    
    
end