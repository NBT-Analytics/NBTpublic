classdef safefid < handle
    % SAFEID - A safe wrapper around MATLAB file handles
    %
    % ## Usage synopsis:
    %
    % % Simplest possible use case
    % import safefid.safefid;
    % f = safefid.fopen('test.txt', 'w');
    % f.fprintf('Hello World!');
    % f.ftell
    % f.fseek(0, 'bof');
    % f.fprintf('I just overwrote the original text');
    % clear f; % Will properly close the low level MATLAB file handle
    %
    % % Wrap an existing MATLAB file handle
    % f = safefid(fopen('test.txt', 'w'));
    % f.fprintf('Hello World again!');
    % clear f; % Will close the underlying MATLAB file handle
    %  
    % % Open file1, file2, file3 for writing
    % fa = safefid({'file1', 'file2', 'file3'}, 'w');
    % % Print Hello World to all files
    % fa.fprintf('Hello World!');
    % % Overwrite only file2
    % fa(2).fseek(0, 'bof');
    % fa(2).fprintf('Bye World!');
    % fa(2) = []; % Will close file2's file handle
    %
    % See also: fopen, fprintf, fseek, ftell, ferror, fgetl, fgets, fread,
    % fscanf, fseek, fwrite
 
    %% Properties
    properties
        Temporary = false;
    end
    
    properties (Access = private)
        FID;
    end
    
    properties (Dependent)
        FileName;
        Valid;
    end
    
    %% Dependent properties
    methods
        
        function fName = get.FileName(obj)
            
            fName = fopen(obj.FID);
            
        end
        
        function valid = get.Valid(this)
            
            valid = false;
            if this.FID > 2
                
                try
                    ftell(this.FID);
                    valid = true;
                catch ME
                    if regexpi(ME.identifier, 'MATLAB:badfid'),
                        valid = false;
                    else
                        rethrow(ME);
                    end
                end
                
            end
            
        end        
        
    end  
    
    %% Public methods
    methods
        
        varargout = subsref(this, s);
       
        count = fprintf(fid, varargin);
        
        pos   = ftell(fid);
        
        status = fseek(fid, offset, origin);
        
        varargout = textscan(fid, varargin);
        
        frewind(fid);
        
        is_valid_fid(fid);
        
        [data, count] = fread(fid, varargin);
        
        % More to be done...
    end
    
    %% Constructor and destructor
    methods (Access = public)        
        
        function this = safefid(varargin)
            import safefid.safefid;
            import exceptions.*;
            
            if nargin < 1, return; end
            
            if iscell(varargin{1}),
                
                if nargin > 1,
                    access = varargin{2};
                else
                    access = '';
                end
                
                if iscell(access) && numel(access) ~= numel(varargin{1}),
                    
                    throw(...
                        InvalidArgument('AccessPermissions', ...
                        ['Number of access permissions must be equal ' ...
                        'to the number of files to be open']));
                    
                elseif ischar(access),
                    
                    access = repmat({access}, size(varargin{1}));
                    
                elseif ~iscell(access) || ~all(cellfun(@(x) ischar(x), ...
                        varargin{2})),
                    
                    throw(...
                        InvalidArgument('AccessPermissions', ...
                        ['Access permissions must be a string or a cell ' ...
                        'array of strings']));
                    
                end                                
                
                for i = 1:numel(varargin{1}),
                  
                    if ischar(varargin{1}{i}),
                        thisTmp(i) = safefid.fopen(varargin{1}{i}, access{i}); 
                    else
                        thisTmp(i) = safefid(varargin{1}{i}); %#ok<*AGROW>
                    end
                    
                end
                this = thisTmp;
                
            elseif ischar(varargin{1}),
                
                this = safefid.fopen(varargin{:});
                
            elseif isnumeric(varargin{1}) && varargin{1} > 0,
                
                this.FID = varargin{1};
                
            else
                
                this.FID = -1;
                
            end
            
            
            
        end        
        
        function delete(this)
            
            if (this.Valid),
                fName = this.FileName;
                fclose(this.FID);
                
                if this.Temporary && exist(fName, 'file'),
                    delete(fName);
                end
                
            end
            
        end                
        
    end
    
    %% Static contructors
    methods (Static)
        
        function varargout = fopen(varargin)
            import safefid.safefid;
            
            if nargin == 1 && isa(varargin{1}, 'safefid'),
                varargout{1} = varargin{1}.FileName;
                return;
            end
            
            s(1).type = '.';
            s(1).subs = 'fopen';
            s(2).type = '()';
            s(2).subs = varargin;
            if nargout > 0,
                lhs = 'varargout{%d} ';
                lhs = repmat(lhs, 1, nargout);
                lhs = ['[' sprintf(lhs, 1:nargout) ']='];
            else
                lhs = 'varargout{1}=';
            end
            eval(...
                sprintf(...
                '%sfeval(''%s'', s(2).subs{:});', ...
                lhs, s(1).subs) ...
                );
            
            if ischar(varargout{1}), %#ok<*NODEF>
                
                return;
                
            elseif all(varargout{1} > 0),
                % One or more FIDs in varargout{1}
                this = safefid(varargout(1));
                varargout{1}    = this;  
                
            else
                
                varargout{1} = safefid(varargout(1));
            
            end
            
        end
        
        function this = fopentmp(varargin)
            import safefid.safefid;
            
            this = safefid.fopen(varargin{:});
            
            this.Temporary = true;
            
        end
        
    end
    
    
    
    
end