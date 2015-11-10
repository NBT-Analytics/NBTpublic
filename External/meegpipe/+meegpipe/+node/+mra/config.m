classdef config < meegpipe.node.abstract_config
    % CONFIG - Configuration of mra nodes
    %
    % See: <a href="matlab:misc.md_help('meegpipe.node.mra.config')">misc.md_help(''meegpipe.node.mra.config'')</a>
    
    
    
    %% PUBLIC INTERFACE ...................................................
    
    properties
        
        NN             = 20;             % Number of nearest neighbors
        SearchWindow   = [60*5 60*5];    % In seconds
        EventSelector  = physioset.event.class_selector('tr');
        TR             = 2000;
        NbSlices       = 1;
        LPF            = 40;
        TemplateFunc   = @(x) mean(x, 2);
        
    end
    
    % Consistency checks to be done
    methods
        
        % Global consistency check
        function check(obj)
            import exceptions.Inconsistent;
            
            if isempty(obj.TR) || isempty(obj.NbSlices),
                throw(Inconsistent(...
                    'Properties TR and NbSlices must be provided'));
            end
            
            if isempty(obj.NN),
                throw(Inconsistent('Property NN must be specified'));
            end
            
            if isempty(obj.SearchWindow),
                throw(Inconsistent(...
                    'Property SearchWindow must be specified'));
            end
            
        end
        
        function obj = set.NN(obj, value)
            
            import exceptions.InvalidPropValue;
            import misc.isnatural;
            import goo.from_constructor;
            
            if isempty(value),
                throw(InvalidPropValue('NN', 'Cannot be empty'));
            end
            
            if numel(value) ~= 1 || ~isnatural(value),
                throw(InvalidPropValue('NN', ...
                    'Must be a natural scalar'));
            end
            
            obj.NN = value;
            
            if ~from_constructor(obj),
                check(obj);
            end
            
        end
        
        function obj = set.SearchWindow(obj, value)
            
            import exceptions.InvalidPropValue;
            import goo.from_constructor;
            
            if isempty(value),
                throw(InvalidPropValue('SearchWindow', 'Cannot be empty'));
            end
            
            if numel(value) == 1 && isnumeric(value),
                value = [value, value];
            end
            
            if numel(value) ~= 2 || any(value < 0),
                throw(InvalidPropValue('SearchWindow', ...
                    'Must be a positive scalar'));
            end
            
            obj.SearchWindow = reshape(value, 1, 2);
            
            if ~from_constructor(obj),
                check(obj);
            end
            
        end
        
        function obj = set.EventSelector(obj, value)
            
            import exceptions.InvalidPropValue;
            import goo.from_constructor;
            
            if isempty(value),
                throw(InvalidPropValue('EventSelector', 'Cannot be empty'));
            end
            
            if numel(value) ~= 1 || ...
                    ~isa(value, 'physioset.event.selector'),
                throw(InvalidPropValue('EventSelector', ...
                    'Must be a physioset.event.selector'));
            end
            
            obj.EventSelector = value;
            
            if ~from_constructor(obj),
                check(obj);
            end
            
        end
        
        function obj = set.TR(obj, value)
            
            import exceptions.InvalidPropValue;
            import goo.from_constructor;
            import misc.isnatural;
            
            if isempty(value),
                throw(InvalidPropValue('TR', 'Cannot be empty'));
            end
            
            if numel(value) ~= 1 || ~isnatural(value),
                throw(InvalidPropValue('TR', ...
                    'Must be a natural scalar (# of milliseconds)'));
            end
            
            obj.TR = value;
            
            if ~from_constructor(obj),
                check(obj);
            end
            
        end
        
        function obj = set.NbSlices(obj, value)
            
            import exceptions.InvalidPropValue;
            import misc.isnatural;
            import goo.from_constructor;
            
            if isempty(value),
                throw(InvalidPropValue('NbSlices', 'Cannot be empty'));
            end
            
            if numel(value) ~= 1 || ~isnatural(value),
                throw(InvalidPropValue('NbSlices', ...
                    'Must be a natural scalar (# of slices within a TR)'));
            end
            
            obj.NbSlices = value;
            
            if ~from_constructor(obj),
                check(obj);
            end
            
        end
        
        function obj = set.LPF(obj, value)
            
            import exceptions.InvalidPropValue;
            import goo.from_constructor;
            
            if isempty(value),
                throw(InvalidPropValue('LPF', 'Cannot be empty'));
            end
            
            if numel(value) ~= 1 || ~isnumeric(value) || value < 0,
                throw(InvalidPropValue('LPF', ...
                    'Must be a positive scalar (cutoff frequency)'));
            end
            
            obj.LPF = value;
            
            if ~from_constructor(obj),
                check(obj);
            end
            
        end
        
        function obj = set.TemplateFunc(obj, value)
            
            import exceptions.InvalidPropValue;
            import goo.from_constructor;
            
            if isempty(value),
                throw(InvalidPropValue('TemplateFunc', 'Cannot be empty'));
            end
            
            if numel(value) ~= 1 || ~isa(value, 'function_handle'),
                throw(InvalidPropValue('TemplateFunc', ...
                    'Must be a function_handle'));
            end
            
            obj.TemplateFunc = value;
            
            if ~from_constructor(obj),
                check(obj);
            end
            
        end
        
        
    end
    
    
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@meegpipe.node.abstract_config(varargin{:});
            
        end
        
    end
    
    
    
end