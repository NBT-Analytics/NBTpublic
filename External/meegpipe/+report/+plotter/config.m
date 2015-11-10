classdef config < goo.abstract_setget_handle
    % CONFIG - Configuration for class report.plotter
    %
    % * This class is a helper class for class report.plotter. This class
    %   implements consistency checks that are necessary for a succesful
    %   construction of a report.plotter class.
    %
    % ## Usage synopsis:
    % 
    %   % Define a custom Remark gallery generator  
    %   myGallery = report.gallery('ThumbWidth', 350);
    %
    %   % Define a custom snapshot plotter
    %   myPlotter = physioset.plotter.snapshots('ScaleFactor', 4);
    %
    %   % Build a report configuration object
    %   import report.plotter.*;
    %   myReportConfig = config('Gallery', myGallery, 'Plotter', myPlotter);
    %
    %   % Build the report object
    %   myReport = plotter(myReportConfig);
    %
    %   % Alternatively, you could have done directly:
    %   myReport = plotter('Gallery', myGallery, 'Plotter', myPlotter);
    %
    %
    % ## Accepted configuration options (as key/value pairs):
    %
    %       ExtraLinks: Logical scalar. Default: true
    %           If set to true, links to the "extra" figures will not be
    %           included in the report. See the documentation of the
    %           relevant plotter for information regarding such "extra"
    %           figures.
    %
    %       Folder: A pathname (a string). Default: ''
    %           The directory where the report files should be placed. If
    %           left empty, the report will be generated under
    %           [sessFolder]/+reportdb where [sessFolder] is the current
    %           session directory.
    %
    %       Plotter: A physioset.plotter.time.snapshots object. 
    %           Default: physioset.plotter.time.snapshots
    %           The plotter to use for generating the snapshots. You can
    %           provide an array of objects of any class that implements 
    %           the physioset.plotter.plotter interface. You may also define 
    %           your own plotter that implements such interface.          
    %
    %       Gallery: A report.gallery object. Default: report.gallery
    %           The gallery generator to use for generating the Remark
    %           gallery. Galleries with custom looks can be defined by
    %           building a report.gallery object with custom properties
    %           (see example in the usage synopsis above).
    %
    %
    % See also: report.plotter, report.gallery
    
    % Description: Helper configuration class
    % Documentation: class_config.txt


    %% PUBLIC INTERFACE ...................................................

    
    properties    
        
        Plotter           = {physioset.plotter.snapshots.snapshots};
        ExtraLinks        = false;    
        Gallery           = report.gallery.gallery;
        PrintGalleryTitle = true;
        
    end
    
    % Consistency checks (set methods)
    methods       
        
        function set.ExtraLinks(obj, value)
            
            import exceptions.*;
            if isempty(value),
                obj.ExtraLinks = false;
                return;
            end
            
             if ~islogical(value) || numel(value) > 1,
                throw(InvalidPropValue('ExtraLinks', ...
                    'Must be a logical scalar'));
             end
            obj.ExtraLinks = value;            
            
        end
   
        function set.Gallery(obj, value)
            
            import exceptions.*;
               
            if isempty(value),
                value = remark_gallery;
            end
            
            if ~isa(value, 'report.gallery.gallery'),
                throw(InvalidPropValue('Gallery', ...
                    'Must be a gallery object'));
            end
            
            if numel(value) ~= 1,
                throw(InvalidPropValue('Gallery', ...
                    'Must be a single remark_gallery object'));
            end
            
            obj.Gallery = value;
            
        end
        
        function set.Plotter(obj, value)   
            
           import exceptions.*; 
            
           if isempty(value),
               value = physioset.plotter.snapshots.snapshots;
           end
           
           if numel(value) == 1 && ~iscell(value),
               value = {value};           
           end
           
           if numel(value) > 1 && ~iscell(value),
               throw(InvalidPropValue('Plotter', ...
                        ['Must be a cell array of ' ...
                        'gallery_plotter objects']));
           end     
           
           if ~all(cellfun(...
                   @(x) goo.pkgisa(x, 'report.gallery_plotter'), ...
                   value)),
                throw(InvalidPropValue('Plotter', ...
                        'Must be a gallery_plotter'));
           end     
           
           obj.Plotter = value;
         
        end
        
    end
    
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@goo.abstract_setget_handle(varargin{:});            
          
        end
        
    end
    
end