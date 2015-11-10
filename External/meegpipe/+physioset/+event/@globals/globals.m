classdef (Sealed) globals < dynamicprops
    % GLOBALS - Global variables for package pset.event
    %
    % globals.evaluate.[varname]
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
    %   folder a globals.txt file. For instance, if a user would like to
    %   change the value of the FileNaming and Precision variables of
    %   package pset.import, he or she should perform these steps:
    %
    %   1) Create a file +globals/+pset/globals.txt. The folder
    %      +globals can be anywhere, as long as it is in MATLAB's search
    %      path. 
    %
    %   2) Edit the contents of +globals/+pset/globals.txt so that
    %      it reads:
    %
    %      FileNaming   Random
    %      Precision    Double
    %
    %   All variables that are not especified in the +globals folder will 
    %   the values specified in the globals.txt file located in the same
    %   folder as this class definition file. An important note is that the
    %   user MAY NOT define variables in the user-defined globals.txt that
    %   do not exist already in the system globals.txt. 
    %   
    %
    %
    % See also: pset
    
   % Documentation: pset_globals.txt
   % Description: Global variables

    properties (SetAccess = private)
        File;
        UserFile = '+globals/+pset/+event/globals.txt';
    end
    methods (Access = private)
        function obj = globals
            import misc.strtrim;
           
            % Read globals from settings file
            path = fileparts(mfilename('fullpath'));
            obj.File = [path filesep 'globals.txt'];
            
            obj = physioset.event.globals.read_file(obj);                          
            
            if exist(obj.UserFile, 'file'),
                obj = goo.globals.read_file(obj, obj.UserFile, false);
            end
            
        end
    end
    methods (Static)
        function singleObj = evaluate

            persistent localObj
            if isempty(localObj) || ~isvalid(localObj)
                localObj = physioset.event.globals;
            end
            singleObj = localObj;
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
                % If the value is an object of a class in the current
                % namespace, we have to be careful to avoid an infinite
                % recursion (if the constructor of such an object uses
                % some package specific global variable).
                idx = regexpi(C{2}{i}, '^physioset.event.');
                if ~isempty(idx)
                    obj.(C{1}{i}) = strtrim(C{2}{i});
                else
                    try
                        obj.(C{1}{i}) = eval(C{2}{i});
                    catch %#ok<CTCH>
                        obj.(C{1}{i}) = strtrim(C{2}{i});
                    end
                end
            end
        end
    end
    
end