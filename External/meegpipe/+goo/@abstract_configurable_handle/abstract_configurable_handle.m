classdef abstract_configurable_handle < ...
        goo.configurable_handle & ...
        goo.clonable
    
    properties (GetAccess = private, SetAccess = private)
        
        Config;
        
    end
    
    methods
        
        % goo.configurable interface
        obj     = set_config(obj, varargin);
        val     = get_config(obj, varargin);
        val     = get_config_reference(obj, varargin);        
        disp_body(obj);
        obj = clone(obj);
        
        % default implementations defined here
        disp(obj);
        
        % Virtual constructor
        function obj = abstract_configurable_handle(varargin)
            
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