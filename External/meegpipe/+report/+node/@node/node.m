classdef node < report.generic.generic
    
  
    properties (SetAccess = private, GetAccess = private)
       
        Node_;  % A ref to a pset.node.node object
        
    end
    
    % Consistency checks (set methods)
    methods
        
        function obj = set.Node_(obj, value)
            
            import goo.pkgisa;
            import exceptions.*;
            
            if isempty(obj) || ~pkgisa(value, 'meegpipe.node.node') || ...
                    ~initialized(value),
                throw(InvalidPropValue('Node_', ...
                    'Must be an initialized node object'));
            end
            
            obj.Node_ = value;
            
        end
    end
 
    % overrides methods of class report.generic.generic
    methods (Access = protected)
        
        fileName  = def_filename(obj);
        
        [repFolder, repFilesFolder] = def_rootpath(obj, varargin);
       
    end
    
    methods        
         
        obj = initialize(obj);        
        
    end
    
    % Constructor
    methods
        
        function obj = node(nodeObj, varargin)
            import exceptions.*;
            import goo.pkgisa;
            import mperl.file.spec.catdir;
            import mperl.file.spec.catfile;
            
            if nargin < 1 || isempty(nodeObj),
                throw(InvalidArgValue('nodeObj', 'Must be a node object'));
            end
            
            obj = obj@report.generic.generic(nodeObj, varargin{:});      
            
            if pkgisa(nodeObj, 'report'),
                % Copy constructor;
                obj.Node_ = nodeObj.Node_;
                nodeObj   = nodeObj.Node_;
            else
                obj.Node_ = nodeObj;
            end          
           
            if isempty(get_title(obj)),
                set_title(obj, get_full_name(nodeObj));
            end
            
            nodeFullDir = get_full_dir(nodeObj);
            set_rootpath(obj, [nodeFullDir filesep 'remark']);
            
            % Copy index.htm and pyserver.bat
            indexFile = [report.root_path, filesep 'index.htm'];
            pyservFile = [report.root_path, filesep 'pyserver.bat'];
            copyfile(indexFile, [nodeFullDir filesep 'index.htm']);
            copyfile(pyservFile, [nodeFullDir filesep 'pyserver.bat']);
            
            % Set parent to report of parent node
            parentNode = get_parent(nodeObj);
            if ~isempty(parentNode)              
                childof(obj, get_report(get_parent(nodeObj)));                
            end           
            
                 
        end
        
    end
    
    
end