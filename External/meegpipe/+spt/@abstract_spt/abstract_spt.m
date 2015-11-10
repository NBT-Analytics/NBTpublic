classdef abstract_spt < ...
        spt.spt             &  ...
        goo.printable       &  ...   % fprintf()
        goo.verbose         &  ...   % is_verbose()/set_verbose()
        goo.method_config   & ....   % set/get_method_config
        goo.abstract_named_object
    % ABSTRACT_SPT - Common ancestor for all spatial transforms
    
    properties (SetAccess = private, GetAccess = private)
        % Handling random state and random initialization
        RandState_;
        Init_;
        
        % History of components/dims selections
        ComponentSelectionH = {};
        DimSelectionH = {};
        
    end
    
    properties (SetAccess = protected, GetAccess = protected)
        
        W;                   % Projection matrix
        A;                   % Backprojection matrix
        ComponentSelection;  % Indices of selected components
        DimSelection;        % Indices of selected data dimension
        
    end
    
    properties
        LearningFilter;     % Pre-processing filter before learning
    end
    
    
    properties (Dependent)
        
        DimIn;
        DimOut;
        
    end
    
    methods
        
        function val = get.DimIn(obj)
            val = numel(obj.DimSelection);
        end
        
        function val = get.DimOut(obj)
            val = numel(obj.ComponentSelection);
        end
        
        function obj = set.LearningFilter(obj, value)
            import exceptions.InvalidPropValue;
            
            if isempty(value),
                obj.LearningFilter = [];
                return;
            end
            
            if numel(value) ~=1 || (~isa(value, 'filter.dfilt') && ...
                    ~isa(value, 'function_handle')),
                throw(InvalidPropValue('LearningFilter', ...
                    'Must be a filter.dfilt object or a function_handle'));
            end
            
            obj.LearningFilter = value;
            
        end
        
    end
    
    methods (Access = private)
        
        function obj = backup_selection(obj)
            
            if isempty(obj.DimSelection) && isempty(obj.ComponentSelection),
                return;
            end
            
            obj.DimSelectionH = [obj.DimSelectionH; {obj.DimSelection}];
            obj.ComponentSelectionH = [obj.ComponentSelectionH; ...
                {obj.ComponentSelection}];
            
        end
        
        
    end
    
    methods
        
        % Mutable methods from spt.spt interface
        
        obj      = sort(obj, sortingFeature, varargin);
        
        % Method learn() is implemented in terms of learn_basis() which is to
        % be implemented by concrete classes that inherit from abstract_spt
        obj      = learn(obj, data, varargin);
        
        obj      = match_sources(source, target, varargin);
        
        function obj = select_component(obj, idx, varargin)
            obj = select(obj, idx, [], varargin{:});
        end
        
        function obj = select_dim(obj, idx, varargin)
            obj = select(obj, [], idx, varargin{:});
        end
        
        obj      = select(obj, compIdx, dimIdx, backup);
        
        function obj = clear_selection(obj)
            obj.ComponentSelection = 1:size(obj.A,1);
            obj.DimSelection = 1:size(obj.A, 2);
        end
        
        obj = restore_selection(obj);
        
        varargout = cascade(varargin);
        
        function obj = reorder_component(obj, idx)
            
            obj.W = obj.W(idx,:);
            obj.A = obj.A(:, idx);
            selected = false(1, nb_component(obj));
            selected(obj.ComponentSelection) = true;
            obj.ComponentSelection = find(selected(idx));
            
        end
        
        % Inmutable abstract methods
        
        function W  = projmat(obj, fullMatrix)
            if nargin < 2 || isempty(fullMatrix),
                fullMatrix = false;
            end
            
            if fullMatrix,
                W = obj.W;
            else
                W = obj.W(obj.ComponentSelection, obj.DimSelection);
            end
        end
        
        function A  = bprojmat(obj, fullMatrix)
            if nargin < 2 || isempty(fullMatrix),
                fullMatrix = false;
            end
            
            if fullMatrix,
                A = obj.A;
            else
                A = obj.A(obj.DimSelection, obj.ComponentSelection);
            end
        end
        
        [data, I]   = proj(obj, data, full);
        
        [data, I]   = bproj(obj, data, full);
        
        function I = component_selection(obj)
            
            I = obj.ComponentSelection;
            
        end
        
        function I = dim_selection(obj)
            
            I = obj.DimSelection;
            
        end
        
        function val = nb_dim(obj)
            val = size(projmat(obj), 2);
        end
        
        function val = nb_component(obj)
            val = size(projmat(obj), 1);
        end
        
        % Random state and initialization
        function obj  = clear_state(obj)
            
            obj.Init_      = [];
            obj.RandState_ = [];
            
        end
        
        function seed = get_seed(obj)
            
            import misc.isnatural;
            
            if isempty(obj.RandState_) || ~isnatural(obj.RandState_),
                seed = randi(1e9);
            else
                seed = obj.RandState_;
            end
            
        end
        
        function obj  = set_seed(obj, value)
            
            obj.RandState_ = value;
            
        end
        
        function obj = apply_seed(obj)
            randSeed = get_seed(obj);
            warning('off', 'MATLAB:RandStream:ActivatingLegacyGenerators');
            rand('state',  randSeed); %#ok<RAND>
            randn('state', randSeed); %#ok<RAND>
            warning('on', 'MATLAB:RandStream:ActivatingLegacyGenerators');
            obj = set_seed(obj, randSeed);
        end
        
        function init = get_init(obj, ~)
            
            init = obj.Init_;
            
        end
        
        function obj = set_init(obj, value)
            
            obj.Init_ = value;
            
        end
        
        % goo.printable interface
        count = fprintf(fid, obj, varargin); % ok
        
    end
    
    methods (Abstract)
        
        obj = learn_basis(obj, data);
        
    end
    
    
    % Constructor
    methods
        
        function obj = abstract_spt(varargin)
            import misc.process_arguments;
            import misc.split_arguments;
            import misc.set_properties;
            
            if nargin < 1, return; end
            
            obj = goo.abstract_named_object.init_goo_abstract_named_object(obj, varargin{:});
            
            obj = goo.verbose.init_goo_verbose(obj, varargin{:});
            
            parentArgs = {'Name', 'Verbose', 'VerboseLabel', 'VerboseLevel'};
            [~, thisArgs] = split_arguments(parentArgs, varargin);
            
            opt.LearningFilter = [];
            obj = set_properties(obj, opt, thisArgs{:});
            
        end
        
    end
    
    
end