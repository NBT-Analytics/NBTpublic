classdef abstract_physioset_import < ...
        physioset.import.physioset_import & ...
        goo.abstract_setget & ...
        goo.verbose
    % abstract_physioset_import - Ancestor for physioset importer classes
    %
    % See: <a href="matlab:misc.md_help('physioset.import.abstract_physioset_import')">physioset.import.abstract_physioset_import(''physioset.import.abstract_physioset_import'')</a>
    
    
    properties (SetAccess = private, GetAccess = private)        
        StartTime_;        
    end
    
    
    methods (Access = protected)        
        function args = construction_args_pset(obj)
            
            args = {...
                'Precision', obj.Precision, ...
                'Writable',  obj.Writable, ...
                'Temporary', obj.Temporary, ...
                'FileName',  obj.FileName, ...
                'AutoDestroyMemMap', obj.AutoDestroyMemMap, ...
                'StartTime', obj.StartTime_ ...
                };            
        end
        
        % Might be overloaded by children classes
        function args = construction_args_physioset(obj)            
            args = {...
                'MetaMapper', obj.MetaMapper, ...
                'EventMapper', obj.EventMapper};
            
        end
        
    end
    
    properties
        
        Precision    = meegpipe.get_config('pset', 'precision');
        Writable     = meegpipe.get_config('pset', 'writable');
        Temporary    = meegpipe.get_config('pset', 'temporary');
        ChunkSize    = meegpipe.get_config('pset', 'largest_memory_chunk');
        AutoDestroyMemMap = ...
            meegpipe.get_config('pset', 'auto_destroy_mem_map');
        ReadEvents   = true;
        FileName     = '';
        FileNaming   = 'inherit';
        Sensors      = [];
        EventMapping = mjava.hash({'TREV', 'tr', 'TR\s.+', 'tr'});
        MetaMapper   = @(data) regexp(get_name(data), '(?<subject_id>0+\d+)_.+', 'names');
        EventMapper  = [];
        
    end
    
    properties (Dependent)
        StartTime;
    end
    
    methods
        
        %% Dependent properties
        function val = get.StartTime(obj)
            
            dateFmt = meegpipe.get_config('pset', 'date_format');
            timeFmt = meegpipe.get_config('pset', 'time_format');
            val = datestr(obj.StartTime_, [dateFmt ' ' timeFmt] );
            
        end
        
        %% Set methods / consistency checks
        function obj = set.Precision(obj, value)
            
            import exceptions.*;
            
            if ~ischar(value),
                throw(InvalidPropValue('Precision', ...
                    'Must be a string'));
            end
            
            if ~any(strcmpi(value, {'double', 'single'})),
                throw(InvalidPropValue('Precision', ...
                    sprintf('Invalid precision ''%s''', value)));
            end
            
            obj.Precision = value;
            
        end
        
        function obj = set.Writable(obj, value)
            
            import exceptions.*;
            if numel(value) > 1 || ~islogical(value),
                throw(InvalidPropValue('Writable', ...
                    'Must be a logical scalar'));
            end
            obj.Writable = value;
            
        end
        
        function obj = set.Temporary(obj, value)
            
            import exceptions.*;
            if numel(value) > 1 || ~islogical(value),
                throw(InvalidPropValue('Temporary', ...
                    'Must be a logical scalar'));
            end
            
            obj.Temporary = value;
            
        end
        
        function obj = set.ChunkSize(obj, value)
            
            import exceptions.*;
            import misc.isinteger;
            if numel(value) > 1 || ~isinteger(value) || value < 0,
                throw(InvalidPropValue('ChunkSize', ...
                    'The ChunkSize property must be a natural number'));
            end
            obj.ChunkSize = value;
        end
        
        function obj = set.ReadEvents(obj, value)
            
            import exceptions.*;
            if isempty(value) || numel(value) > 1 || ~islogical(value),
                throw(InvalidPropValue('ReadEvents', ...
                    'Must be a logical scalar'));
            end
            
            obj.ReadEvents = value;
            
        end
        
        function obj = set.Sensors(obj, value)
            
            import exceptions.*;
            import goo.pkgisa;
            
            if isempty(value),
                obj.Sensors = [];
                return;
            end
            
            if ~isa(value, 'sensors.sensors'),
                
                throw(InvalidPropValue('Sensors', ...
                    'Must be a sensors.object'));
                
            end
            
            obj.Sensors = value;
            
        end
        
        function obj = set.FileName(obj, value)
            
            import exceptions.*;
            
            if ~ischar(value),
                throw(InvalidPropValue('FileName', ...
                    'Must be a valid file name (a string)'));
            end
            
            [pathName, fileName, ext] = fileparts(value);
            
            if isempty(fileName),
                obj.FileName = '';
                return;
            end
            
            if isempty(pathName), pathName = pwd; end
            
            psetExt = meegpipe.get_config('pset', 'data_file_ext');
            
            if ~isempty(ext) && ~strcmp(ext, psetExt),
                warning('abstract_physioset_import:InvalidExtension', ...
                    'Replaced file extension %s -> %s', ext, psetExt);
            end
            
            value = [pathName, filesep, fileName, psetExt];
            
            obj.FileName = value;
            
        end
        
        function obj = set.EventMapping(obj, value)
            
            import exceptions.*;
            
            if isempty(value),
                obj.EventMapping = [];
                return;
            end
            
            if numel(value) ~= 1 || ~isa(value, 'mjava.hash'),
                throw(InvalidPropValue('EventMapping', ...
                    'Must be a mjava.hash object'));
            end
            obj.EventMapping = value;
            
        end
        
        %% Generic import() and helper methods
        pObj = import(obj, varargin);
        
        % We keep obj as output for backwards compatibility
        [fileName, obj] = resolve_link(obj, fileName)       
        
        %% Constructor       
        function obj = abstract_physioset_import(varargin)
            import misc.split_arguments;
            import misc.process_arguments;
            
            if nargin < 1, return; end
            
            [args1, args2] = split_arguments('StartTime', varargin);
            
            opt.StartTime = [];
            [~, opt] = process_arguments(opt, args1);
            obj.StartTime_ = opt.StartTime;
            
            % Set public properties
            obj = set(obj, args2{:});
            
        end      
    end
    
end