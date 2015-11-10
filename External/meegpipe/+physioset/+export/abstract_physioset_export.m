classdef abstract_physioset_export < ...
        physioset.export.physioset_export & ...
        goo.abstract_setget & ...
        goo.verbose
    % abstract_physioset_export - Ancestor for physioset exporter classes
    %
    % See: <a href="matlab:misc.md_help('physioset.export.abstract_physioset_export')">physioset.abstract_physioset_export(''physioset.export.abstract_physioset_export'')</a>
    
    
    
    %% Private stuff
    properties (SetAccess = private, GetAccess = private)
        
        StartTime_;
        
    end  
    
    
    %% PUBLIC INTERFACE ...................................................
    properties        

        FileName     = '';
        FileNaming   = 'inherit';    
        
    end
  
    % Set methods / consistency checks
    methods
        
        
        function obj = set.FileName(obj, value)
            
            import exceptions.*;
            import pset.globals;
            
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
            
            psetExt = globals.get.DataFileExt;
            
            if ~isempty(ext) && ~strcmp(ext, psetExt),
                warning('abstract_physioset_export:InvalidExtension', ...
                    'Replaced file extension %s -> %s', ext, psetExt);
            end
            
            value = [pathName, filesep, fileName, psetExt];
            
            obj.FileName = value;
            
        end        
     
    end
    
    methods (Abstract)
        
        varargout = export(obj, filename, varargin)
        
    end    
 
    % Constructor
    methods
        
        function obj = abstract_physioset_export(varargin)
            import misc.split_arguments;
            import misc.process_arguments;
            
            if nargin < 1, return; end
        
            % Set public properties
            obj = set(obj, varargin{:});
            
        end
        
    end
    
end