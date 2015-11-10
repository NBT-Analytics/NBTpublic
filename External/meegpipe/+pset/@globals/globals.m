classdef (Sealed) globals < dynamicprops
    % GLOBALS - package global variables
    %
    % eegpipe.globals.evaluate.[varname]
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
    %   file +pset/+node/globals.txt file.
    %
    %
    % See also: pset
    
    % Documentation: class_globals.txt
    % Description: Global variables
    
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
            
            try
                rPath = globals.root_path;
                obj.UserFile = catfile(rPath, '+pset', '+node', 'globals.txt');
            catch ME
                if ~strcmpi(ME.identifier, 'MATLAB:undefinedVarOrClass'),
                    rethrow(ME);
                end
                obj.UserFile = '';
            end
            
            obj = pset.globals.read_file(obj);
            
            if exist(obj.UserFile, 'file'),
                obj = pset.globals.read_file(obj, obj.UserFile, false);
            end
            
        end
    end
    
    methods (Static)
        
        function value = get(varargin)
            
            import exceptions.*
            persistent localObj;
            
            if isempty(localObj) || ~isvalid(localObj)
                localObj = pset.globals;
            end
            
            if nargin < 1,
                value = localObj;
            elseif nargin == 1 && ischar(varargin{1}),
                value = localObj.(varargin{1});
            elseif nargin > 1 && all(cellfun(@(x) ischar(x), varargin)),
                value = cellfun(@(x) localObj.(x), varargin, ...
                    'UniformOutput', false);
            else
                throw(InvalidArgument(...
                    'One or more strings are expected as input arguments'));
            end
            
        end
        
        function value = set(varargin)
            
            import pset.globals;
            import exceptions.*
            
            localObj = globals.get;
            value = localObj;
            
            if mod(nargin,2) > 0,
                
                throw(InvalidArgument(...
                    'An even number of input arguments is expected'));
                
            elseif ~all(cellfun(@(x) ischar(x), varargin(1:2:end))),
                
                throw(InvalidArgument('Argument keys must be strings'));
                
            elseif nargin == 2,
                
                localObj.(varargin{1}) = varargin{2};
                
            else
                
                cellfun(@(x, y) globals.set(x,y), varargin(1:2:end), ...
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