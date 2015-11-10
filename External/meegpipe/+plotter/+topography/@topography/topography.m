classdef topography < plotter.plotter & goo.abstract_configurable_handle
    % TOPOGRAPHY - Plots scalp topographies in 2D or 3D
    %
    % This class can be used to generate scalp topographies and easily
    % manipulate figure properties. The main functionality is built around
    % EEGLAB's topoplot function. Thus, this class requires EEGLAB to be
    % present in MATLAB's path.
    %
    % ## Usage synopsis:
    %
    % % Define the plotter configuration
    % import plotter.topography.*;
    % cfg = config('Fiducials', 'off');
    %
    % % A configuration object is optional
    % obj = topography(config);
    %
    % % Create some sample sensors
    % sensorsObj = sensors.eeg.from_template('egi256');
    %
    % % Plot a random topography and get a handle to the result
    % h = plot(obj, sensorsObj, rand(nb_sensors(sensorsObj),1));
    %
    % % Do not show ears and nose
    % set_ears_and_nose(h, 'Visible', 'off');
    %
    % % Display a colorbar and then hide it
    % colorbar(h);
    % set_colorbar(h, 'Visible', 'off');
    %
    % % Display sensor labels in a tiny font
    % set_sensor_labels(h, 'Visible', 'on', 'FontSize', 6);
    %
    % % Use sensor numbers instead of labels
    % labels2numbers(h);    
    %
    % % Invert the colors of the figure (i.e. use a black background)
    % blackbg(h);
    %
    % See also: config, plot
    
    % Description: Class definition
    % Documentation: class_plotter_topography_topography.txt
    
    %% IMPLEMENTATION .....................................................
    
    properties (SetAccess = private, GetAccess = private)   
        
        Figure;
        Axes;
        HeadContour;
        EarsAndNose;
        Rim;            % Must have same color as Figure
        ContourSurface;
        ContourLines;
        ColorBar;
        SensorMarkers;
        SensorLabels;
        FiducialMarkers;
        FiducialLabels;
        ExtraMarkers;
        ExtraLabels;
        Sensors;        % Sensor information
        Fiducials;
        Extra;
        Data;           % The data being plotted
    end
    
    % Set methods for private properties
    methods 
        
        function set.Figure(obj, value)
            obj.Figure = value;
            nbRefs = get(obj.Figure, 'UserData');
            if isempty(nbRefs),
                set(obj.Figure, 'UserData', 1);
            else
                set(obj.Figure, 'UserData', nbRefs+1);                
            end
        end                
        
    end
    
    % Helper methods
    methods (Access = private)     
        
        args = topoplot_args(obj);       
        
    end
    
    %% PUBLIC INTERFACE ...................................................
   
    % plotter.plotter interface
    methods
        
        obj = clone(obj);
        
        obj = plot(obj, varargin);       
        
        obj = blackbg(obj, varargin);         
        
    end    
    
    % Own methods
    methods
        
        colorbar(obj);
        
        obj = set_figure(obj, varargin);
        
        obj = set_axes(obj, varargin);
        
        obj = set_head_contour(obj, varargin);
        
        obj = set_ears_and_nose(obj, varargin);
        
        obj = set_contour_surface(obj, varargin);
        
        obj = set_contour_lines(obj, varargin);
        
        obj = set_colorbar(obj, varargin);
        
        obj = set_colorbar_title(obj, varargin);
        
        obj = set_sensor_markers(obj, varargin);
        
        obj = set_sensor_labels(obj, varargin);
        
        obj = set_fiducial_markers(obj, varargin);
        
        obj = set_fiducial_labels(obj, varargin); 
        
        obj = set_extra_markers(obj, varargin);
        
        obj = set_extra_labels(obj, varargin);
        
        obj = labels2numbers(h);
        
        obj = numbers2numbers(h);
           
        value = get_figure(obj, varargin);
        
        value = get_axes(obj, varargin);
        
        value = get_head_contour(obj, varargin);
        
        value = get_ears_and_nose(obj, varargin);
        
        value = get_contour_surface(obj, varargin);
        
        value = get_contour_lines(obj, varargin);
        
        value = get_colorbar(obj, varargin);
        
        value = get_colorbar_title(obj, varargin);
        
        value = get_sensor_markers(obj, varargin);
        
        value = get_sensor_labels(obj, varargin);
        
        value = get_fiducial_markers(obj, varargin);
        
        value = get_fiducial_labels(obj, varargin);
        
        value = get_extra_markers(obj, varargin);
        
        value = get_extra_labels(obj, varargin);
        
        value = get_sensor_idx(obj, label);
        
        value = get_fiducial_idx(obj, label);
        
        value = get_extra_idx(obj, label);
        
    end
    
    % Constructor
    methods
        function obj = topography(varargin)
           
            obj = obj@goo.abstract_configurable_handle(varargin{:});
            
        end
    end
    
    % Destructor
    methods
        function delete(obj)
            if get_config(obj, 'DeleteOnDestroy') && ...
                    ~isempty(obj.Figure) && ...
                    ishandle(obj.Figure) && obj.Figure > 0           
                delete(obj.Figure);               
            end
        end
    end
    
end