classdef config < goo.abstract_setget_handle
    % CONFIG - Configuration for class gallery
    %
    %
    % ## Usage synopsis:
    %
    %   % Create a gallery object with custom thumbnails width
    %   import report.gallery.*;
    %   myConfig = config('ThumbWidth', 200);
    %   myGallery = gallery(myConfig);
    %
    %   % Alternatively, you could have done directly this:
    %   myGallery = gallery('ThumbWidth', 400)
    %
    %
    % ## Accepted configuration options (as key/value pairs):
    %
    %       ThumbHeight: A natural scalar. Default: 250
    %           Height in pixels of the generated thumbnails
    %
    %       ThumbWidth: A natural scalar. Default: 250
    %           Width, in pixels, of the generated thumbnails.
    %
    %       NoThumbs: A logical scalar. Default: false
    %           If set to true, no thumbnails will be plotted regarless of
    %           whether a gallery figure has the thumbnail flag set to
    %           true. See method add_figure for more information.
    %
    %       NoLinks: A logical scalar. Default: false
    %           If set to true, no links will be generated in the gallery,
    %           regardless of the value of the Link flag of a given gallery
    %           figure. See method add_figure for more information.
    %
    %       ThumbsRegex: A regular expression (a string). Default: '.+'
    %           If NoThumbs is set to false, only the files that match this
    %           regular expression will have corresponding thumbnails.
    %
    %       LinksRegex: A regular expression (a string). Default: '.+'
    %           If NoLinks is set to false, only the files that match this
    %           regular expression will be linked to, using explicit links.
    %
    %
    %
    % See also: gallery
    
    % Description: Configuration for class gallery
    % Documentation: pkg_report_gallery.txt
    
    
    %% PUBLIC INTERFACE ...................................................
    properties
        
        NoThumbs     = false;
        ThumbsRegex  = '.+';
        NoLinks      = true;
        LinksRegex   = '.+';
        Level        = 1;
        Title        = '';
        ThumbHeight  = 250;
        ThumbWidth   = 250;
        
    end
    
    % Consistency checks (set methods)
    methods
        
        function set.NoThumbs(obj, value)
            import exceptions.*;
            
            if isempty(value), value = false; end
            
            if ~islogical(value) || numel(value) > 1,
                throw(InvalidPropValue('NoThumbs', ...
                    'Must be a logical scalar'));
            end
            obj.NoThumbs = value;
        end
        
        function set.ThumbsRegex(obj, value)
            import exceptions.*;
            
            if isempty(value), value = '.+'; end
            
            if ~ischar(value) || ~isvector(value) || size(value, 1) > 1,
                throw(InvalidPropValue('ThumbsRegex', ...
                    'Must be a regular expression (a string)'));
            end
            obj.ThumbsRegex = value;
            
        end
        
        function set.NoLinks(obj, value)
            import exceptions.*
            
            if isempty(value), value = false; end
            
            if ~islogical(value) || numel(value) > 1,
                throw(InvalidPropValue('NoLinks', ...
                    'Must be a logical scalar'));
            end
            obj.NoLinks = value;
        end
        
        function set.LinksRegex(obj, value)
            import exceptions.*;
            
            if isempty(value), value = '.+'; end
            
            if ~ischar(value) || ~isvector(value) || size(value, 1) > 1,
                throw(InvalidPropValue('LinksRegex', ...
                    'Must be a regular expression (a string)'));
            end
            obj.LinksRegex = value;
            
        end
        
        function set.Level(obj, value)
            import misc.isnatural;
            import exceptions.*
            
            if isempty(value),
                value = 2;
            end
            
            if ~isnatural(value) || numel(value) ~= 1,
                throw(InvalidPropValue('Level', ...
                    'Must be an integer scalar'));
            end
            
            if value < 1,
                throw(InvalidPropValue('Level', 'Must be greater than 1'));
            end
            
            obj.Level = value;
        end
        
        function set.Title(obj, value)
            
            import misc.is_string;
            import exceptions.*
            
            if isempty(value),
                obj.Title = '';
                return;
            end
            
            if ~is_string(value)
                throw(InvalidPropValue('Title', 'Must be a string'));
            end
            
            obj.Title = value;
            
        end
        
        function set.ThumbHeight(obj, value)
            
            import exceptions.*
            import misc.isnatural;
            if isempty(value),
                obj.ThumbHeight = 250;
                return;
            end
            
            if numel(value)~=1 || ~isnatural(value),
                throw(InvalidPropValue('ThumbHeight', ...
                    'Must be a natural scalar'));
            end
            obj.ThumbHeight = value;
            
        end
        
        function set.ThumbWidth(obj, value)
            
            import exceptions.*
            import misc.isnatural;
            if isempty(value),
                obj.ThumbWidth = 250;
                return;
            end
            
            if numel(value)~=1 || ~isnatural(value),
                throw(InvalidPropValue('ThumbWidth', ...
                    'Must be a natural scalar'));
            end
            obj.ThumbWidth = value;
            
        end
        
    end
    
    
    % Contructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@goo.abstract_setget_handle(varargin{:});
            
        end
        
    end
    
end