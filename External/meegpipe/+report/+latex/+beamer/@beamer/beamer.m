classdef beamer < handle
    % BEAMER - Create beamer-based Latex slides
    %
    %
    % See also: latex
    
    properties (SetAccess = private, GetAccess = private)
        
        RootDir;
        FID;                    % contains a safefid.safefid object
        ColorTheme = 'Black';
        Theme;
        
    end
    
    % Consistency checks
    methods
       
        function set.FID(obj, value)
           
            import exceptions.*;
            if isempty(value),
                obj.FID = [];
                return;
            end
            
            if numel(value) ~= 1 || ~isa(value, 'safefid.safefid'),
                throw(InvalidPropValue('FID', ...
                    'Must be a safefid.safefid object'));
            end
            obj.FID = value;
            
        end
        
    end   
    
    methods (Access = private)
       
        begin_document(obj);
        end_document(obj);
        
    end
    
    
    
    %% Public interface ...................................................
    
    % Public (dependent) properties
    properties (Dependent)
        
       FileName;
       
    end
    
    % Simple redirections to methods of class safefid.safefid
    methods        
        
         function value = get.FileName(obj)
        
            if isempty(obj.FID),
                value = '';
            else
                value = obj.FID.FileName;
            end
        
        end
        
        
        function count = fprintf(obj, varargin)
           
            count = fprintf(obj.FID, varargin{:});
            
        end
      
    end
    
    % Other public methods
    methods
       
        begin_slide(obj, title);
        include_graphics(obj, h, caption, varargin); 
        end_slide(obj);
        print_paragraph(obj, text, size);
        begin_plain_slide(obj);
        end_plain_slide(obj);
        
    end
    
    
    % Constructor and destructor
    methods
        
        
        function obj = beamer(name, varargin)
            
            import misc.process_arguments;
            import mperl.file.spec.*;
            
            if nargin < 1 || isempty(name),
                name = ['beamer-' date2str(now, 'yy.mm.dd-hh.mm.ss')];
            end
                            
            opt.RootDir    = catdir(pwd, name);
            opt.ColorTheme = 'Black';
            opt.Theme      = '';
            
            [~, opt] = process_arguments(opt, varargin);
            
            if ~exist(opt.RootDir, 'dir'),
                mkdir(opt.RootDir);
            end
            
            obj.RootDir    = opt.RootDir;
            
            fName = catfile(obj.RootDir, 'beamer.tex');
            obj.FID        = safefid.safefid(fName, 'w');
            obj.ColorTheme = opt.ColorTheme;
            obj.Theme      = opt.Theme;
            
            begin_document(obj);
            
        end
        
        function delete(obj)
            
            end_document(obj);
            
        end
        
    end
    
    
end