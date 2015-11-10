classdef (Sealed) globals < dynamicprops
    % GLOBALS - Package global variables
    %
    % import filter.plotter.fvtool2.globals;
    % globals.get.[varname]
    %
    %
    % Where
    %
    % [VARNAME] denotes the name of the global variable whose value we want
    % to evaluate
    %
    %
    % ## Notes:
    %
    % * The values of the global values can be modified by editting the
    %   text file globals.txt, located in the same folder as this class
    %   definition file.
    %
    % * In a shared computing environment, it is not recommended to edit
    %   the globals.txt file, as this change will become inmmediately
    %   effective for all other users of the package. If a user wants to
    %   modify the value of a global variable it can do so by adding a
    %   folder +globals to MATLAB's search path and creating within that
    %   folder a globals.txt file at the right subdirectory. For instance,
    %   if a user would like to change the value of the FileNaming and
    %   Precision variables of package pset.import, he or she should 
    %   perform these steps:
    %
    %   1) Create a file +globals/+pset/+import/globals.txt. The folder
    %      +globals can be anywhere, as long as it is in MATLAB's search
    %      path.
    %
    %   2) Edit the contents of +globals/+pset/+import/globals.txt so that
    %      it reads:
    %
    %      FileNaming   Random
    %      Precision    Double
    %
    %   All variables that are not especified in the +globals folder will
    %   the values specified in the globals.txt file located in the same
    %   folder as this class definition file. An important note is that the
    %   user MAY NOT define variables in the user-defined globals.txt that
    %   do not exist already in the system's globals.txt.
    %
    % See also: fvtool2
    
    % Documentation: pkg_fvtool2.txt
    % Description: Package global variables
   
    properties (SetAccess = private)
        
        File;
        UserFile;        
        
    end
    
    % Private constructor
    methods (Access = protected)
        
        function obj = globals
            import misc.strtrim;           
            import mperl.file.spec.catfile;
            
            % Read globals from settings file
            path         = fileparts(mfilename('fullpath'));
            obj.File     = [path filesep 'globals.txt'];
            
            stem = regexprep(obj.File, '^([^+@]*)(\+|@).+$', '$1');
            pkg  = regexprep(obj.File, ...
                ['^' strrep(stem, '\', '\\') '(\+*.*)@.+globals.txt$'], ...
                '$1');
            
            obj.UserFile = catfile(stem, '+globals', pkg, 'globals.txt');
            
            obj = filter.plotter.fvtool2.globals.read_file(obj);
            
            if exist(obj.UserFile, 'file'),
                obj = filter.plotter.fvtool2.globals.read_file(obj, obj.UserFile, false);
            end
            
        end
        
    end
    
    methods (Static)
        
        function value = get(varargin)     
            
            persistent localObj;
            if isempty(localObj) || ~isvalid(localObj)
                localObj = filter.plotter.fvtool2.globals;                
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
            
            localObj = filter.plotter.fvtool2.globals.get;
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
                cellfun(@(x, y) filter.plotter.fvtool2.globals.set(x,y), varargin(1:2:end), ...
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