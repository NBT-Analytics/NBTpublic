classdef gallery < goo.printable_handle & goo.abstract_configurable_handle
    % GALLERY - Highslide gallery class
    %
    % This class implements a Remark gallery. It stores information
    % regarding such gallery (image file names, image captions, etc.) and
    % it provides method fprintf() to print a Remark gallery onto an open
    % file
    %
    % ## Usage synopsis:
    %
    % % Construct a gallery object
    % import report.gallery;
    % galObj = gallery('Title', 'My Gallery');
    %
    % % Assume myfile.png and another.png exist
    % galObj = add_figure(galObj, 'myfile.png', 'A nice picture');
    % galObj = add_figure(galObj, 'another.png', 'Another nice picture');
    %
    % % Print to file
    % fid = fopen('report.txt', 'w');
    % fprintf(fid, galObj);
    % fclose(fid);
    %
    % The code above will print the following Remark code to the text file
    % 'report.txt' (lines starting with $$ will not be printed):
    %
    % $$ BEGIN report.txt
    %     ## My Gallery
    %
    %     [[set_many Gallery]]:
    %          thumbnail_max_width 250
    %          thumbnail_max_height 250
    %
    %     [[Gallery]]:
    %
    %         myfile.png
    %
    %         - A nice picture
    %
    %         another.png
    %
    %         - Another nice picture
    %
    % $$ END report.txt
    %
    %
    % ## Notes:
    %
    %   * Gallery images file names must be relative to the
    %     directory where the report text file is located.
    %
    %
    % See also: config, demo, make_test
    
    properties (SetAccess = private, GetAccess = private)
        
        Files        = {};
        Captions     = {};
        ThumbNail    = {};  % Print thumbnail for image?
        Link         = {};  % Print link for image?
        Level        = 1;
        Title        = '';
        
    end
    
    methods
        
        % Accessors
        nbFigs    = nb_figures(obj);
        
        fileTitle = get_filename(obj, idx);
        
        ref       = get_ref(obj, idx);
        
        caption   = get_caption(obj, idx);
        
        disp(obj);
        
        % Modifiers
       
        obj       = print_figure(myGallery, hFig, rep, name, caption);
        
        obj       = add_figure(obj, fileName, caption, thumb, link);
        
        % goo.printable interface
        count = fprintf(fid, varargin);
        
    end
    
    % Constructor
    methods
        
        function obj = gallery(varargin)
            
            obj = obj@goo.abstract_configurable_handle(varargin{:});
            
        end
        
    end
    
end