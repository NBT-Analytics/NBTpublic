classdef abstract_node < ...
        meegpipe.node.node                  & ...
        goo.abstract_configurable_handle    & ...
        goo.verbose_handle                  & ...
        goo.hashable_handle                 & ...
        goo.reportable_handle
    % ABSTRACT_NODE - Common ancestor to all meegpipe.node.node classes
    %
    % This class serves as a common ancestor to final node classes. It
    % implements properties and methods shared among all node classes. When
    % defining new classes that implement the meegpipe.node interface it is
    % preferable to inherit from this class rather than directly from
    % meegpipe.node. Constructors of children classes are expected to call the
    % abstract constructor of this class.
    %
    % ## Abstract constructor:
    %
    % import meegpipe.node.abstract_node;
    % obj = abstract_node('key', value, ...)
    %
    %
    % ## Accepted key/value pairs:
    %
    % * Note: keys match class property names
    %
    %
    %       Name: A string. Default: ''
    %           A name identifying the node instance
    %
    %       Save: Logical scalar. Default: false
    %           If set to true, the output of method process will be saved
    %           to a disk file.
    %
    %       OGE: Logical scalar. Default: true
    %           If set to true, method process() will attempt to use Oracle
    %           Grid Engine to process multiple datasets in parallel.
    %           Obviously this property is meaningful only if OGE is
    %           available in this system, i.e. if the following MATLAB
    %           command returns true:
    %
    %               oge.has_oge
    %
    %       Queue: String. Default: 'long.q'
    %           The OGE queue where the jobs should be submitted
    %
    %       DataSelector: A pset.selector.selector objects. Default: []
    %           This data selector will be used to select the data that is
    %           to be processed by the node.
    %
    %       GenerateReport: Boolean. Default: true
    %           If set to false, no HTML report will be generated.
    %
    %
    % See also: node
    
    properties
        Name           = '';
        DataSelector   = pset.selector.all_data;
        Parallelize    = meegpipe.node.globals.get.Parallelize;
        Queue          = meegpipe.node.globals.get.Queue;
        Save           = meegpipe.node.globals.get.Save;
        GenerateReport = meegpipe.node.globals.get.GenerateReport;
        TempDir        = '';
        % The pipeline ID is dependent on the version of meegpipe.
        % Sometimes you want to override this default behavior and impose
        % an explicit ID on the pipe. The reason: re-run the analysis on a
        % pipeline result obtained with a version of meegpipe different from
        % the current one.
        FakeID = '';
    end
    
    properties (SetAccess = private, GetAccess = private)
        
        TrainingModel  = []; % May be used to store the output of train()
        IOReport       = []; % Will be ignored when converting to struct
        
        % Properties with a _ postfix will not be considered when
        % converting object to struct. Therefore, they will not be
        % considered when obtaining the object's hash code.
        
        Report_;     % must be initialized in constructor (is handle)
        ProcReport_;  % for future use
        Tic_          = [];
        SuperGlobals_ = struct;
        Globals_      = struct;
        RunTime_      = [];
        Static_       = [];
        RootDir_      = [];
        SaveDir_      = [];      % Same as RootDir_ but this is not reset in finalize()
        VersionFile_  = [];
        Parent_       = [];      % the parent node (probably a pipeline), if any
        NodeIdx_      = [];      % the index of this node within a pipeline
        SavedNode_    = '';
        SavedInput_   = '';
        Diagnostics_  = struct;
    end
    
    %% Consistency checks
    methods
        
        function obj = set.Name(obj, value)
            
            import exceptions.*;
            import misc.isstring;
            
            if ~isempty(value),
                if ~isstring(value),
                    throw(InvalidPropValue(...
                        'Name',  'Must be a string'));
                end
                obj.Name = value;
            else
                obj.Name = '';
            end
            
            
        end
        
        function obj = set.Save(obj, value)
            
            import exceptions.*;
            
            if isempty(value),
                value = meegpipe.node.globals.get.Save;
            end
            
            if ~islogical(value) || numel(value)~=1,
                throw(InvalidPropValue(...
                    'Save', ...
                    'Must be a logical scalar'));
            end
            
            obj.Save = value;
            
        end
        
        function obj = set.Parallelize(obj, value)
            import exceptions.*;
            if isempty(value),
                value = meegpipe.node.globals.get.Parallelize;
            end
            if ~islogical(value) || numel(value)~=1,
                throw(InvalidPropValue(...
                    'Parallelize', ...
                    'Must be a logical scalar'));
            end
            obj.Parallelize = value;
        end
        
        function obj = set.Queue(obj, value)
            
            import exceptions.*;
            import misc.isstring;
            
            if isempty(value),
                value = meegpipe.node.globals.get.Queue;
            end
            
            if ~isstring(value),
                throw(InvalidPropValue(...
                    'Queue',  'Must be a string'));
            end
            
            obj.Queue = value;
            
        end
        
        function obj = set.DataSelector(obj, value)
            
            import exceptions.*;
            import goo.pkgisa;
            
            if isempty(value),
                obj.DataSelector = [];
                return;
            end
            
            if ~pkgisa(value, 'pset.selector.selector'),
                throw(InvalidPropValue('DataSelector', ...
                    'Must be a data selector'));
            end
            obj.DataSelector = value;
            
        end
        
        function obj = set.GenerateReport(obj, value)
            import exceptions.*;
            if isempty(value),
                value = meegpipe.node.globals.get.GenerateReport;
            end
            if ~islogical(value) || numel(value)~=1,
                throw(InvalidPropValue(...
                    'GenerateReport', ...
                    'Must be a logical scalar'));
            end
            obj.GenerateReport = value;
        end
        
    end
    
    %% Helper methods
    methods (Access = private)
        
        % Set/get Tic_
        obj = set_tinit(obj, report);
        
        value = get_tinit(obj, report);
        
        % Set the Report_ property
        obj = set_report(obj, report);
        
        % Private configuration options, e.g. static/runtime hash codes
        ini = get_static_config(obj);
        
        obj = set_static(obj, varargin);
        
        value = get_static(obj, varargin);
        
        % Runtime parameters are stored here
        ini  = get_runtime_config(obj, forceRead);
        
        % run using OGE
        outputFile = run_oge(obj, data);
        
        % Generate I/O report
        report      = io_report(obj, input, output);
        
        restore_global_state(obj);
        
        % File where the meegpipe version is stored
        fileName = get_vers_file(obj);
        
        
    end
    
    methods (Access = protected)
        
        dirName = get_data_dir(obj, data);
        
    end
    
    % Construction keys handled by this class, to be used in constructors
    % of children classes to split own and parent arguments
    methods (Access = protected, Static)
        
        function props = construction_keys
            props = {'Name', 'Save', 'Queue', 'Parallelize', ...
                'DataSelector', 'GenerateReport', 'TempDir', 'FakeID', ...
                'TrainingModel'};
        end
        
        
    end
    
    %% PROTECTED interface
    methods (Access = protected)
        
        % Should the node generate a report?
        bool = do_reporting(obj);
        
        % Gets the time elapsed as a human readable string
        str = get_duration(obj);
        
        % Make a node a child of another node
        obj = childof(obj, parentObj, childIdx);
        
        % node input/output reports
        report      = input_report(obj, input);
        
        report      = output_report(obj, output);
        
        % runtime parameters
        obj         = clear_runtime(obj);
        
        obj         = set_runtime(obj, section, param, varargin);
        
        value       = get_runtime(obj, section, param, varargin);
        
        % diagnostic information
        obj         = set_diagnostic(obj, varargin);
        
        % Override this if your node does not have runtime configuration
        function bool = has_runtime_config(~)
            
            bool = false;
            
        end
        
        % Change detection
        bool        = has_changed_runtime(obj);
        
        bool        = has_changed_config(obj);
        
        bool        = has_changed(obj);
        
        
        data = save(obj, data, varargin);
        
        % Called from run()
        obj         = initialize(obj, data);
        
        data        = preprocess(obj, data);
        
        data        = postprocess(obj, data);
        
        obj         = finalize(obj, data, dataIn);
        
        % set/get io report
        rep         = get_io_report(obj);
        
        obj         = set_io_report(obj, rep);
        
        % Operate with log files
        fid         = get_log(obj, filename);
        
        
    end
    
    %% meegpipe.node.node interface
    methods
        
        % Accessors
        
        % A name that contains only word characters
        name                 = get_name(obj);
        
        % The actual name of the node (may contain any character)
        name                 = get_full_name(obj)
        
        oge                  = get_oge(obj);
        
        dataSel              = get_data_selector(obj);
        
        save                 = get_save(obj);
        
        repObj               = get_report(obj);
        
        repObj               = get_proc_report(obj);
        
        fileName             = get_output_filename(obj, data);
        
        fileName             = get_ini_filename(obj);
        
        dirName              = get_dir(obj);        
        
        dirName              = get_tempdir(obj);        
        
        dirName              = get_save_dir(obj);
        
        parentNode           = get_parent(obj);
        
        
        % Will call method process of final classes
        [dataOut, dataNew] = run(obj, dataIn, varargin);
        
        % Copy constructor
        newObj = clone(obj);
        
        % Modifiers
        obj                  = set_name(obj, name);
        
        obj                  = set_oge(obj, oge);
        
        obj                  = set_data_selector(obj, dataSel);
        
        obj                  = set_save(obj, save);
        
        % Data conversion
        
        % this is required by get_hash_code(). Be careful not to include
        % fields that contain references to Parent nodes or you will end up
        % with an infinite recursion
        str         = struct(obj);
        
        % Get root directory of report
        dirName     = get_full_dir(obj, data);
        
        % meegpipe version with which the node was last run
        vers = get_meegpipe_version(obj);
        
        
    end
    
    % Not in the node interface, but introduced (and implemented) here
    methods
        
        bool            = initialized(obj);
        
        queue           = get_queue(obj);
        
        nodeFileName    = saved_node(obj);
        
        inputFileName   = saved_input(obj);
        
        value           = get_diagnostics(obj, varargin);
        
        figH            = attach_figure(obj, figH);
        
        disp(obj);
        
        disp_body(obj);
        
        % Default implementation of train() does nothing
        function myNode = train(myNode, varargin)
            % do nothing
        end
        
        function myNode = set_training_model(myNode, trainModel)
            myNode.TrainingModel = trainModel;
        end
        
        function model = get_training_model(obj)
            model = obj.TrainingModel;
        end
        
        function hash = get_training_hash(obj)
            hash = obj.TrainingHash;
        end
        
    end
    
    %% meegpipe.types.hashable_handle interface
    methods
        
        hashCode            = get_hash_code(obj);
        % get_id is what is used to name the output directory
        hashCode            = get_id(obj);
        hashCode            = get_static_hash_code(obj);
    end
    
    %% goo.reportable_handle interface
    methods
        
        [pName, pVal, pDescr] = report_info(obj)
        
        function str = whatfor(~)
            str = '';
        end
        
    end
    
    %% To be implemented by final classes
    methods (Abstract)
        
        [dataOut, varargout] = process(obj, dataIn, varargin);
        
    end
    
    % Constructor
    methods
        
        function obj = abstract_node(varargin)
            import misc.struct2cell;
            import misc.process_arguments;
            import misc.split_arguments;
            import meegpipe.node.abstract_node;
            import goo.get_cfg_class;
            
            % Default verbose label
            obj = set_verbose_label(obj, ...
                @(obj, ~) sprintf('(%s) ', get_name(obj)));
            
            props = abstract_node.construction_keys;
            
            if nargin > 0 && isa(varargin{1}, 'meegpipe.node.node'),
                %% Copy constructor
                
                objO  = varargin{1};
                
                for i = 1:numel(props)
                    obj.(props{i}) = objO.(props{i});
                end
                
                % Now clone the config
                if ~isempty(get_config(varargin{1})),
                    % Realize that get_config returns a config clone!
                    obj = set_config(obj, get_config(varargin{1}));
                end
                
                % IMPORTANT: Do not clone the Report_ property, which
                % should be initialized during node initialization. In
                % general, any XX_ property should not be cloned.
                
                % And clone the i/o report
                if ~isempty(varargin{1}.IOReport),
                    obj.IOReport = clone(varargin{1}.IOReport);
                end
                
                % Leave the reference to the parent, if any
                
                obj.Parent_ = objO.Parent_;
                
                
                return;
                
            elseif nargin == 1 && isa(varargin{1}, get_cfg_class(obj)),
                
                obj = set_config(obj, clone(varargin{1}));
                return;
                
            end
            
            %% set object properties
            
            % A fix for backwards compatibility. Older property "OGE"  has
            % been replaced by property "Parallelize".
            for i = 1:2:numel(varargin),
                if strcmpi(varargin{i}, 'oge'),
                    varargin{i} = 'Parallelize';
                end
            end
            
            [thisArgs, args] = ...
                split_arguments(props, varargin);
            if ~isempty(thisArgs),
                fNames = unique(thisArgs(1:2:end));
                opt    = cell2struct(repmat({[]}, 1, numel(fNames)), fNames, 2);
                [~, opt] = process_arguments(opt, thisArgs);
                
                for i = 1:numel(fNames)
                    obj.(fNames{i}) = opt.(fNames{i});
                end
            end
            
            %% set some special properties: Config, IOReport
            [thisArgs, args] = ...
                split_arguments({'Config', 'IOReport'}, args);
            if ~isempty(thisArgs),
                opt.Config   = [];
                opt.IOReport = [];
                [~, opt] = process_arguments(opt, thisArgs);
                fNames = fieldnames(opt);
                for i = 1:numel(fNames)
                    if ~isa(opt.(fNames{i}), 'handle'), continue; end
                    obj.(fNames{i}) = clone(opt.(fNames{i}));
                end
            end
            
            % Verbose
            [thisArgs, configArgs] = ...
                split_arguments({'Verbose'}, args);    %#ok<NASGU>
            opt.Verbose = true;
            [~, opt] = process_arguments(opt, thisArgs);
            set_verbose(obj, opt.Verbose);
            
            %% set configuration options
            
            cfg = eval([get_cfg_class(obj) '(configArgs{:})']);
            set_config(obj, cfg);
            
        end
        
        
    end
    
    
    
end
