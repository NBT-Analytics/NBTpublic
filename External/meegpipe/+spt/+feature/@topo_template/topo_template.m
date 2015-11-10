classdef topo_template < spt.feature.feature & goo.verbose
    % TOPO_TEMPLATE - Topographical template match
    
    properties
        
        Template;
        
    end
    
    methods
        
        function obj = set.Template(obj, value)
            import exceptions.InvalidPropValue;
            
            if isempty(value),
                obj.Template = [];
                return;
            end
            
            if numel(value) ~= 1 || ~isa(value, 'function_handle'),
                throw(InvalidPropValue('Template', ...
                    'Must be a function_handle'));
            end
            obj.Template = value;            
        end
        
    end
    
    methods (Static)
        
        
        function template = bcg_template(data, varargin)
            
            import physioset.search_processing_history;
            
            nodeList = search_processing_history(data, 'obs');
            
            if isempty(nodeList),
                template = [];
                warning('topo_template:NoTemplate', ...
                    'No template could be built based on processing history');
                return;
            end
            
            template = get_bcg_erp(nodeList{1});
            
        end
        
    end
    
    
    
    % Static constructors
    methods (Static)
        
        function obj = bcg(varargin)
            
            obj = spt.feature.topo_template('Template',  ...
                @(data) spt.feature.topo_template.bcg_template(data));
            
        end
        
    end
    
    
    methods
        
        [featVal, featName] = extract_feature(obj, sptObj, varargin)
        
        % Constructor
        function obj = topo_template(varargin)
            import misc.set_properties;
            
            if nargin < 1, return; end
            
            opt.Template = [];           
            obj = set_properties(obj, opt, varargin);
            
        end
        
    end
    
    
    
end