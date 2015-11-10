classdef config < ...
        goo.abstract_setget_handle  & ...
        goo.reportable_handle
    % CONFIG.TOPOGRAPHY - Configuration for pset.plot.topography
    %
    % cfg = pset.plotter.config.topography;
    % cfg = pset.plotter.config.topography('key', value, ...)
    % cfg = set(cfg, 'key', value, ...)
    % value = get(cfg, 'key')
    %
    %
    % ## Accepted key/value pairs:
    %
    %       Normalized: Logical vector. Default: false
    %           Specifies whether the topographical plots are to be
    %           normalized. If Normalized is a vector then it must have the
    %           same dimensions as Stats (see below). In the latter case,
    %           each element of Normalized determines whether or not to
    %           normalize a given statistic.
    %
    %       Folder: A valid directory name (a string). Default: ''
    %           The figures will be saved to this directory.
    %
    %       Plotter: A plotter.topography object.
    %           Default: plotter.topography
    %
    %
    % See also: pset.plotter.topography
    
    
    % Public interface ....................................................
    properties
        
        BlackBgPlots = false;
        PrintDrivers = {}; %{'pdf'}
        Normalized   = false;
        Folder       = '';
        Plotter      = plotter.topography.topography( 'Visible',  false);
        Resolution   = goo.globals.get.ImageResolution;
        
    end
    
    % Consistency checks
    methods
        function obj = set.BlackBgPlots(obj, value)
            if isempty(value), value = true; end
            
            if ~islogical(value) || numel(value) ~= 1,
                throw(abstract_config.InvalidPropValue('BlackBgPlots', ...
                    'Must be a logical scalar'));
            end
            obj.BlackBgPlots = value;
        end
        
        
        function obj = set.PrintDrivers(obj, value)
            
            if ischar(value),
                value = {value};
            end
            
            if ~all(cellfun(@(x) ischar(x) && ~isempty(x), value)),
                throw(abstract_config.InvalidPropValue('PrintDrivers', ...
                    'Must be a cell array of strings'));
            end
            
            obj.PrintDrivers = value;
            
        end
        
        function obj = set.Normalized(obj, value)
            if ~islogical(value) || numel(value)~=1,
                throw(abstract_config.InvalidPropValue('Normalized', ...
                    'Must be a logical scalar'));
            end
            obj.Normalized = value;
        end
        
        function obj = set.Folder(obj, value)
            if isempty(value),
                obj.Folder = '';
                return;
            end
            
            if ~ischar(value) || ~isvector(value),
                throw(abstract_config.InvalidPropValue('Folder', ...
                    'Must be a string'));
            end
            
            % see whether this is a valid folder name
            if ~exist(value, 'dir'),
                success = mkdir(value);
                if success,
                    rmdir(value);
                else
                    throw(abtract_config.InvalidPropValue('Folder', ...
                        sprintf('Dir %s does not seem to be valid', value)));
                end
            end
            
            obj.Folder = value;
            
        end
        
        function obj = set.Plotter(obj, value)            
         
            if isempty(value),
                obj.Plotter = plotter.topography;
                return;
            end
            
            if numel(value) ~= 1 || ...
                    ~isa(value, 'plotter.topography.topography'),
                throw(abstract_config.InvalidPropValue('Plotter', ...
                    'Must be of class plotter.topography.topography'));
            end
            obj.Plotter = value;
        end
        
        
    end
    
    % report.reportable interface
    methods
        [pName, pValue, pDescr]   = report_info(obj, varargin);
        
        function str = whatfor(~)
            str = '';
        end
        
    end
    
    % Constructor
    methods
        
        function obj = config(varargin)
       
            obj = obj@goo.abstract_setget_handle(varargin{:});
            
        end
    end
    
    
    
end