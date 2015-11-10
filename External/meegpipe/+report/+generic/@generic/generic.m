classdef generic < report.report
    
    properties (SetAccess = private, GetAccess = private)
        
        RootPath    = '';
        FileName    = '';
        Parent      = '';        
        FID         = [];
        CloseFID    = true;
        
        Level       = 1;
        Title       = '';
        
    end
    
    % Set methods, basic consistency checks
    methods
        
        function set.RootPath(obj, value)
            import exceptions.*
            import goo.prop_change_event_data;
            import mperl.cwd.abs_path;
            
            if isempty(value),
                obj.RootPath = '';
                return;
            end
            
            if ~ischar(value) || ~isvector(value),
                throw(InvalidPropValue('RootPath', ...
                    'Must be a path name (a string)'));
            end
            
            if ~isempty(value),
                if~exist(value, 'dir'),
                    mkdir(value);
                end
                value = abs_path(value);
            end
            
            oldPath      = obj.RootPath;
            obj.RootPath = value;
            
            notify(obj, 'RootPathChange', ...
                prop_change_event_data('RootPath', oldPath, value));
            
        end
        
        function set.FileName(obj, value)
            import exceptions.*
            import mperl.file.spec.abs2rel;
            
            if isempty(value),
                obj.FileName = '';
                return;
            end
            
            if ~ischar(value) || ~isvector(value),
                throw(InvalidPropValue('FileName', ...
                    'Must be a string'));
            end
            
            obj.FileName = value;
            
        end
        
        function set.Parent(obj, value)
            import exceptions.*
            if isempty(value),
                obj.Parent = '';
                return;
            end
            if ~ischar(value) || ~isvector(value),
                throw(InvalidPropValue('Parent', ...
                    'Must be a file name (a string)'));
            end
            obj.Parent = value;
        end
      
        function set.FID(obj, value)
            import exceptions.*
            import misc.is_valid_fid;
            
            if isempty(value),
                obj.FID = [];
                return;
            end
            
            if isa(value, 'safefid.safefid') && ~value.Valid,
                throw(InvalidPropValue('FID', ...
                    'Must be a valid safefid.safefid object'));
            end
            
            obj.FID = value;
            
        end
        
        function set.CloseFID(obj, value)
            import exceptions.*
            
            if nargin < 2 || isempty(value),
                value = true;
            end
            if numel(value) ~= 1 || ~islogical(value),
                throw(InvalidPropValue('CloseFID', ...
                    'Must be a logical scalar'));
            end
            obj.CloseFID = value;
        end
        
        function set.Level(obj, value)
            import exceptions.*
            import goo.prop_change_event_data;
            if isempty(value),
                obj.Level = 1;
                return;
            end
            if ~isnumeric(value) || numel(value) ~= 1 || ...
                    value < 1 || value > 4
                throw(InvalidPropValue('Level', ...
                    'Must be a scalar in the range 1-4'));
            end
            
            oldLevel  = obj.Level;
            obj.Level = value;
            
            notify(obj, 'LevelChange', ...
                prop_change_event_data('Level', oldLevel, value));
            
        end
        
        function set.Title(obj, value)
            import exceptions.*
            if isempty(value),
                obj.Title = '';
                return;
            end
            if ~ischar(value) || ~isvector(value),
                throw(InvalidPropValue('Title', ...
                    'Must be a string'));
            end
            
            obj.Title = value;
            
        end
        
    end
    
    methods (Static, Access = private)
        
        % Listener for RootPathChange events
        function update_rootpath(src, evnt)
            
            import mperl.file.spec.*;
            
            % Ensure FileName and Parent are relative to new RootPath
            src.FileName = abs2rel(rel2abs(src.FileName, evnt.OldValue), ...
                evnt.NewValue);
            
            src.Parent   = abs2rel(rel2abs(src.Parent, evnt.OldValue), ...
                evnt.NewValue);
            
        end
        
    end
 
    % Own methods
    methods (Access = protected)
        
        % Const methods       

        % parent remark report file
        parent      = get_parent(obj);
        
        parent      = get_abs_parent(obj);
        
        % open file handle to the associated remark file
        fid      	= get_fid(obj);
        
        % default name of the associated remark file
        fName       = def_filename(obj);
        
        % default rootpath
        rPath       = def_rootpath(obj);
        
        % Modifiers
        
        % associate generator to remark file
        set_filename(obj, fname);
        
        % define root of report dir tree
        set_rootpath(obj, rpath);
        
        % associate report generator to an already open file handle
        set_fid(obj, fid);        
    
        % Close associated file handle
        obj = finalize(obj);
        
    end
    
    % Notifies a change in RootPath
    events (ListenAccess = 'protected', NotifyAccess = 'private')
        
        RootPathChange;
        LevelChange;
        
    end
    
    methods
        
        % make generator obj a child of generator parent
        obj = childof(obj, parent);
        
        % embed report OBJ into report TARGETREPORT
        obj = embed(obj, targetReport);        
    
        % Print arbitrary text to report
        count = fprintf(obj, varargin);
        
        % Same as fprintf but assumes text and breaks lines
        count = print_text(obj, varargin);       
        
        % Remark macros/syntax
        fName = print_image(obj, name, varargin);
        
        count = print_paragraph(obj, varargin);
        
        count = print_parent(obj, parent);
        
        count = print_title(obj, title, varargin);
        
        count = print_code(obj, code, varargin);
        
        count = print_link(obj, target, name);
        
        count = print_link2report(rep, targetReport, name);
        
        count = print_ref(obj, target, name);
        
        count = print_file_link(obj, target, name);
        
        count = print_gallery(obj, gallery, varargin);        
        
        % overrides parent class setget_handle's method
        obj = set(obj, varargin);
        
        % set/get report title and associated level
        obj = set_title(obj, title);
        
        obj = set_level(obj, level);
        
        ref     = get_ref(obj);
        
        title   = get_title(obj);
        
        level   = get_level(obj);
        
        % root dir of the report directory tree
        fPath   = get_rootpath(obj);
        
        % remark report filename
        fName   = get_filename(obj);
        
        fName   = get_abs_filename(obj);                
     
        % get report properties or meta-properties
        val     = get(obj, prop);
        
        % Prepare generator to run generate(), mostly associate the
        % generator to a valid open file handle
        obj = initialize(obj, data);   
        
        % true if report is already associated with an open file handle
        bool = initialized(obj);        
        
        % Generate report
        obj = generate(obj, varargin);
        
        % compile the report using Remark
        obj = compile(obj);
        
        % Other methods
        disp(obj);
      
    end
    
    
    % Constructor
    methods
        
        function obj = generic(varargin)
            
            import goo.get_cfg_class;
            import goo.pkgisa;
            import misc.split_arguments;
            
            if nargin < 1, return; end
            
            if nargin == 1 && pkgisa(varargin{1}, 'report.report'),
             % Copy constructor
                % Note: FileName and FID are not copied. 
                fNames = {'RootPath', 'Parent', ...
                    'CloseFID', 'Level', 'Title'};
                for i = 1:numel(fNames)
                    obj.(fNames{i}) = varargin{1}.(fNames{i});
                end
                
                % Now clone the config
                if ~isempty(get_config(varargin{1})),
                    cfgClone  = clone(get_config(varargin{1}));
                    obj = set_config(obj, cfgClone);
                end
                
                return;
            end
            
            count = 1;
            while count <= nargin && ~ischar(varargin{count})
                count = count + 1;
            end
            varargin = varargin(count:end);
            
            binArgs = {'Title', 'Level', 'Parent', 'RootPath'};
            [args, configArgs] = split_arguments(binArgs, varargin);
            for i = 1:2:numel(args),
                obj.(args{i}) = args{i+1};
            end
            
            obj = set_config(obj, configArgs{:});
         
            addlistener(obj, 'RootPathChange', ...
                @report.generic.generic.update_rootpath);
            
        end
        
    end
    
    % Destructor
    methods
        function delete(obj)
            finalize(obj);
        end
    end
    
    
end