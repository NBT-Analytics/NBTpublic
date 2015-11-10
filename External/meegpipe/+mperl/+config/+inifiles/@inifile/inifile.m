classdef inifile < handle & goo.hashable_handle
    % INIFILE - Class for reading/writing .ini configuration files
    %
    %
    % obj = inifile(filename, 'key', value, ...)
    %
    
    properties (SetAccess = private, GetAccess = private)
        
        HashObject = mjava.hash;
        Pause      = 0.1;
        MaxTries   = 10;
        
    end
    
    % Consistency checks
    
    methods
        
        function set.Pause(obj, value)
            
            import eegpipe.exceptions.*;
            
            if ~isnumeric(value) || numel(value) ~= 1 || value < 0 || ...
                    value > 50,
                throw(InvalidPropValue('Pause', ...
                    'Must be a scalar between 0 and 50 (seconds)'));
            end
            
            obj.Pause = value;
            
        end
        
        function set.MaxTries(obj, value)
            
            import eegpipe.exceptions.*;
            
            if numel(value) ~= 1 || ~isnatural(value) || value > 50,
                throw(InvalidPropValue('MaxTries', ...
                    'Must be a natural scalar in the range [1 50]'));
            end
            
            obj.MaxTries = value;
            
        end
        
    end
    
    % Exceptions that may be thrown by this class' methods
    methods (Static, Access = private)
        
        function obj = InvalidPropValue(prop, msg)
            if nargin < 2 || isempty(msg), msg = ''; end
            if nargin < 1 || isempty(prop), prop = '??'; end
            
            obj = MException(...
                'mperl:config:inifiles:inifile:InvalidPropValue', ...
                sprintf('Invalid %s: %s', ...
                prop, msg));
            
        end
        
        function obj = InvalidArgument(msg)
            if nargin < 1 || isempty(msg), msg = ''; end
            
            obj = MException(...
                'mperl:config:inifiles:inifile:InvalidArgument', ...
                sprintf('Invalid input argument: %s', msg));
            
        end
        
        function obj = MissingFile
            obj = MException(...
                'mperl:config:inifiles:inifile:MissingFile', ...
                sprintf('No .ini file is specified in property ''File'''));
        end
        
        function obj = InvalidFile(msg)
            if nargin < 1 || isempty(msg), msg = ''; end
            obj = MException(...
                'mperl:config:inifiles:inifile:InvalidFile', ...
                sprintf('Invalid .ini file: %s', msg));
        end
        
    end
    
    % Convenience methods
    methods (Static, Access = private)
        
        function value = bool2char(value)
            if value,
                value = '1';
            else
                value ='0';
            end
        end
        
        success = ensure_crlf(fName);
        
    end
    
    properties (Dependent, GetAccess = private)
        
        NewString;
        
    end
    
    methods
        
        function value = get.NewString(obj)
            import mperl.config.inifiles.inifile;
            import mperl.join;
            
            value = {...
                inifile.bool2char(obj.NoCase), ...
                inifile.bool2char(obj.AllowContinue), ...
                inifile.bool2char(obj.AllowEmpty)};
        end
        
    end
    
    % Checks whether the ini file still exists and can be read
    methods (Access = private)
        function check_file(obj)
            import mperl.config.inifiles.inifile;
            
            if isempty(obj.File),
                throw(inifile.MissingFile);
            end
            if ~exist(obj.File, 'file'),
                throw(inifile.InvalidFile(...
                    sprintf('File %s was not found', obj.File)));
            end
            try
                fid = fopen(obj.File, 'r');
            catch ME
                throw(inifile.InvalidFile(sprintf(...
                    'Could not open %s for reading', obj.File)));
            end
            fclose(fid);
        end
    end
    
    properties (SetAccess = private)
        File;
    end
    
    properties
        NoCase;
        AllowContinue;
        AllowEmpty;
    end
    
    % Consistency checks
    methods
        
        function set.File(obj, value)
            import mperl.config.inifiles.inifile;
            import mperl.file.spec.rel2abs;
            if ~isempty(value) && ~ischar(value),
                throw(inifile.InvalidPropValue('File', ...
                    'Must be a non-empty string'));
            elseif isempty(value),
                value = '';
            elseif ~exist(value, 'file'),
                % We should not create the file until we really need to
                % This is done in read(). Don't do it here!
            end
            obj.File = rel2abs(value);
            obj.File = strrep(obj.File, '\', '/');
        end
        
        function set.NoCase(obj, value)
            import mperl.config.inifiles.inifile;
            if ~islogical(value) || numel(value)~=1,
                throw(inifile.InvalidPropValue('NoCase', ...
                    'Must be a logical scalar'));
            end
            obj.NoCase = value;
        end
        
        function set.AllowContinue(obj, value)
            import mperl.config.inifiles.inifile;
            if ~islogical(value) || numel(value)~=1,
                throw(inifile.InvalidPropValue('AllowContinue', ...
                    'Must be a logical scalar'));
            end
            obj.AllowContinue = value;
        end
        
        function set.AllowEmpty(obj, value)
            import mperl.config.inifiles.inifile;
            if ~islogical(value) || numel(value)~=1,
                throw(inifile.InvalidPropValue('AllowEmpty', ...
                    'Must be a logical scalar'));
            end
            obj.AllowEmpty = value;
        end
        
    end
    
    % Public interface
    methods
        value  = val(obj, section, parameter, asArray);
        status = setval(obj, section, parameter, varargin);
        status = set_section_comment(obj, section, varargin);
        obj    = set_file_name(obj, name);
        value  = sections(obj);
        value  = section_exists(obj, section);
        status = push(obj, section, parameter, varargin);
        value  = parameters(obj, section);
        status = newval(obj, section, parameter, varargin);
        value  = groups(obj);
        value  = group_members(obj, group);
        value  = get_section_comment(obj, section, asArray);
        value  = exists(obj, section, parameter);
        status = delval(obj, section, parameter);
        status = delete_section(obj, section);
        status = add_section(obj, section);
        % Methods below are original to this implementation, i.e. do not
        % have equivalents in Perl's module Config::IniFiles
        value  = get_varargin(obj, section);
        obj    = hash(obj, evaluate);
        obj    = read(obj);
        
        % eegpipe.types.hashable interface
        md5    = get_hash_code(obj);
    end
    
    % Constructor
    methods
        
        function obj = inifile(filename, varargin)
            import misc.process_arguments;
            import mperl.config.inifiles.inifile;
            
            if nargin < 1, return; end
            
            opt.nocase                   = false;
            opt.allowcontinue            = true;
            % Note that AllowEmpty is true by default in Perl's Config::IniFiles
            opt.allowempty               = true;
            
            [~, opt] = process_arguments(opt, varargin);
            
            obj.NoCase                   = opt.nocase;
            obj.AllowContinue            = opt.allowcontinue;
            obj.AllowEmpty               = opt.allowempty;
            
            obj.File = filename;
            
            % Ensure that CR/LF are used as end of line characters
            % This function is broken right now. It sometimes leads to the
            % ini file being emptied. Please fix this !
            %inifile.ensure_crlf(obj.File);
            
            
            obj = read(obj);
            
        end
    end
    
    
end