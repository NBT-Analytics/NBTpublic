classdef (Sealed) globals < dynamicprops
    % GLOBALS - Package global variables
    %
    % import test.simple.globals;
    % globals.get.[varname]
    % globals.set(varname, value)
    %
    % Where
    % 
    % VARNAME is the name of a package global variable.
    %
    % VALUE is the value to set for the specified global variable.
    %
    %
    % ## Notes:
    %
    % * The values of the global values can be modified by editting the
    %   text file +test/+simple/@globals/globals.txt.
    %
    % * In a shared computing environment, it is not recommended to edit
    %   the +test/+simple/@globals/globals.txt., as this change will affect
    %   as well all other users of the package. If a user wants to
    %   modify the value of a global variable it can do so by adding a
    %   folder +globals to MATLAB's search path and creating within that
    %   folder a +test/+simple/@globals/globals.txt file. For instance, if
    %   a user would like to change the return code of the 
    %   "all tests successful" and "test died or all passed but wrong # of
    %   tests run" conditions, he or she should follow these steps:
    %
    %   1) Create a file +globals/+test/+simple/@globals/globals.txt. The
    %      root folder +globals can be anywhere, as long as it is in 
    %      MATLAB's search path.
    %
    %   2) Edit the contents of +globals/+test/+simple/@globals/globals.txt
    %      so that it reads:
    %
    %      Success      1
    %      Failure      0
    %
    %   All variables that are not especified in the +globals folder will
    %   take the values specified in +test/+simple/@globals/globals.txt.
    %   Users MAY NOT define variables in the user-defined file (under 
    %   directory +globals) that do not exist already in the system's 
    %   file +test/+simple/@globals/globals.txt
    %
    %
    %
    % See also: test.simple
    
    % Documentation: class_globals.txt
    % Description: Global package variables
   
    properties (SetAccess = private)
        
        File;
        UserFile;        
        
    end
    
    % Private constructor
    methods (Access = protected)
        
        function obj = globals
            import misc.strtrim;           
            import mperl.file.spec.catfile;
            import test.simple.globals;
            
            % Read globals from settings file
            path         = fileparts(mfilename('fullpath'));
            obj.File     = [path filesep 'globals.txt'];
            
            stem = regexprep(obj.File, '^([^+@]*)(\+|@).+$', '$1');
            pkg  = regexprep(obj.File, ...
                ['^' strrep(stem, '\', '\\') '(\+*.*)@.+globals.txt$'], ...
                '$1');
            
            obj.UserFile = catfile(stem, '+globals', pkg, 'globals.txt');
            
            obj = globals.read_file(obj);
            
            if exist(obj.UserFile, 'file'),
                obj = globals.read_file(obj, obj.UserFile, false);
            end
            
        end
        
    end
    
    methods (Static)
        
        function value = get(varargin)           
            import test.simple.globals;
            persistent localObj;
            if isempty(localObj) || ~isvalid(localObj)
                localObj = globals;                
            end
            if nargin < 1,
                value = localObj;
            elseif nargin == 1 && ischar(varargin{1}),
                value = localObj.(varargin{1});
            elseif nargin > 1 && all(cellfun(@(x) ischar(x), varargin)),
                value = cellfun(@(x) localObj.(x), varargin, ...
                    'UniformOutput', false);                
            else
                ME = MException('globals:InvalidInputArg', ...
                    'One or more strings are expected as input arguments');
                throw(ME);
            end            
        end
        
        function value = set(varargin)
            import test.simple.globals;
            localObj = globals.get;
            value = localObj;        
            if mod(nargin,2) > 0,
                ME = MException('globals:InvalidInputArg', ...
                    'An even number of input arguments is expected');
                throw(ME);
            elseif ~all(cellfun(@(x) ischar(x), varargin(1:2:end))),
                ME = MException('globals:InvalidInputArg', ...
                    'Argument keys must be strings');
                throw(ME);
            elseif nargin == 2,
                localObj.(varargin{1}) = varargin{2};
            else
                cellfun(@(x, y) eegpipe.globals.set(x,y), varargin(1:2:end), ...
                    varargin(2:2:end));
            end    
        end 
        
        function obj = read_file(obj, filename, addflag)
            if nargin < 3 || isempty(addflag),
                addflag = true;
            end
            if nargin < 2 || isempty(filename),
                fid = fopen(obj.File);
            else
                fid = fopen(filename);
            end
            C = textscan(fid, '%s%[^\n^#]', 'CommentStyle','#');
            fclose(fid);
            for i = 1:size(C{1},1)
                if addflag,
                    obj.addprop(C{1}{i});
                end
                
                try
                    obj.(C{1}{i}) = eval(C{2}{i});
                catch %#ok<CTCH>
                    obj.(C{1}{i}) = strtrim(C{2}{i});
                end
                
            end
        end
    end
    
end