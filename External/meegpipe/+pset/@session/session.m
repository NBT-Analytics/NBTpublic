classdef (Sealed) session < handle
    % SESSION - Session management
    %
    %
    % pset.session.instance(folder) 
    %
    % Where 
    %
    % FOLDER is the path name of the folder where all session files will be
    % stored. 
    %
    %
    % ## Notes:
    %
    % * This is a singleton class, i.e. there can be only oneinstance of the
    %   the pset.session class in the MATLAB workspace. Deleting this unique
    %   instance will cause the pset.session folder to be erased but only if the
    %   folder is empty
    %
    %
    % See also: pset
    
    properties (GetAccess = private, SetAccess = private)
       
        FolderHistory = {};
        
    end
    
    properties (SetAccess = private)
        Folder;    
    end
    
    % Constructor
    methods (Access = private)
        function obj = session(folder)
            if nargin < 1 || isempty(folder),
                % Generate a random pset.session folder
                folder = 'session_1';
                count = 1;
                while exist(folder, 'dir'),
                    count = count + 1;
                    folder = ['session_' num2str(count + 1)];
                end
            end            
              
            if ~exist(folder, 'dir')
                mkdir(folder);
            end            
            obj.Folder = folder;    
        end
    end
    
    % Static method that returns a singleton instance of class pset.session
    methods (Static)
        
        function [singleObj, created] = instance(folder, varargin)
            % Creates the pset.session
            
            import misc.process_varargin;
            THIS_OPTIONS = {'force'};
            force = false;
            eval(process_varargin(THIS_OPTIONS, varargin));                
                        
            if nargin < 1, 
                folder = []; 
            end
            created = false;            
            persistent localObj
            if isempty(localObj) || ~isvalid(localObj) || force
                if isempty(folder)
                    % Create a new pset.session
                    folder = 'session_1';
                    count = 1;
                    while exist(folder, 'dir'),
                        count = count + 1;
                        folder = ['session_' num2str(count + 1)];
                    end
                    mkdir(folder);
                    warning('session:NewSession', ...
                        'A new session was created in folder ''%s''', ...
                        folder);                                    
                elseif exist(folder, 'dir'),
                    folder = what(folder);
                    folder = folder.path;
                else
                    mkdir(folder);
                    folder = what(folder);
                    folder = folder.path;
                end
                
                localObj = pset.session(folder);
                created = true;
            end
            singleObj = localObj;
        end
        
        function obj = subsession(folder, varargin)
            import pset.session;
            import mperl.file.spec.catdir;
            import mperl.file.spec.rel2abs;
            import datahash.DataHash;
            
            if nargin < 1, 
                hashStr = DataHash(randn(1,100));
                folder = hashStr(1:5); 
            end
            
            [obj, created] = session.instance(folder);            
            
            % there was a previous session
            if ~created,
                obj.FolderHistory = [obj.FolderHistory; obj.Folder];
                
                folder = rel2abs(folder, obj.Folder);
                
                obj.Folder = folder;
                if ~exist(obj.Folder, 'dir'),                    
                    mkdir(obj.Folder);                  
                end
            end
            
        end
        
        function obj = clear_subsession()
            import pset.session;
            
            obj = session.instance;
            if exist(obj.Folder, 'dir') && length(dir(obj.Folder)) < 3,
                rmdir(obj.Folder);
            end
            if ~isempty(obj.FolderHistory)
                prevFolder = obj.FolderHistory{end}; 
                obj.Folder = prevFolder;
                obj.FolderHistory = obj.FolderHistory(1:end-1);  
            end
            
        end        
        
    end
    
    % Public interface
    methods
        save(obj, folder);
        load(obj);
        fileName = tempname(obj);
    end
    
    % Destructor
    methods
        function delete(obj)
            if exist(obj.Folder, 'file') && length(dir(obj.Folder)) < 3,
                rmdir(obj.Folder);
            end
        end
    end
    
end