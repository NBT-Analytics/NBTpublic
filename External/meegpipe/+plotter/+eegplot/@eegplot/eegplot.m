classdef eegplot < plotter.plotter & goo.abstract_configurable_handle
    % EEGPLOT - Plots EEG time-series
    %
    % This class is wrapper around EEGLAB's eegplot() function. It allows
    % to easily modify the figure looks.
    %
    % ## Usage synopsis:
    %
    % % Define the plotter configuration, e.g. we want data to be plotted
    % % in different colors for each channel:
    % import plotter.eegplot.*;
    % config = config('Color', 'on', 'SamplingRate', 100);
    %
    % % The configuration object is optional
    % h = eegplot(config);
    %
    % % Create some sample sensors
    % sensorsObj = sensors.eeg.from_template('egi256');
    % sensorsObj = subset(sensorsObj, 1:10);
    %
    % % Plot some random data (using overlays)
    % myEvent   = pset.event.event(50, 'Type', 'myEvent');
    % d1        = randn(10, 100);
    % d2        = randn(10, 100);
    % d3        = randn(10, 100);
    % h = plot(h, d1, d2, d3, 'Events', myEvent);
    % set_sensor_labels(h, 'String', labels(sensorsObj));
    %
    % % Use a black background color
    % blackbg(h);
    %
    % % Create a clone figure
    % h2 = clone(h);
    %
    %
    % See also: plotter.eegplot.config, plotter.eegplot.demo
    

    properties (SetAccess = private, GetAccess = private)
        
        Figure;
        NbPoints;
        NbDims;        
        Axes;
        AxesBg;
        EyeLine;
        Scale;
        ScaleNum;
        ScaleVal;
        MeanVal;
        Line;
        NbTimeSeries;
        EventLine;
        EventLabel;
        OverlaySelection;
        
    end
    
    methods (Access = private)
        
        args    = eegplot_args(obj);
        
        h       = plot_new(obj, data, varargin);
        
        h       = plot_overlay(obj, data, varargin);
        
    end
    
    %% PUBLIC INTERFACE ...................................................
    
    properties (Dependent)
        Selection;
    end
    
    methods
        
        function value = get.Selection(obj)
            
            if isempty(obj.OverlaySelection),
                value = 1;
            else
                value = obj.OverlaySelection;
            end
            
        end
        
    end
    
    % plotter.plotter interface
    methods
        
        obj = clone(obj);
        
        obj = plot(obj, varargin);
        
        obj = blackbg(obj, varargin);
        
    end
    
    % Own methods
    methods
        
        % Modifiers
        
        obj  = set_figure(obj, varargin);
        
        obj  = set_axes(obj, varargin);
        
        obj  = set_line(obj, varargin);
        
        obj  = set_line_color(obj, varargin);
        
        obj  = set_scale(obj, idx, val);
        
        obj  = set_scale_axes(obj, varargin);
        
        obj  = set_scale_label(obj, varargin);
        
        obj  = set_scale_num(obj, varargin);
        
        obj  = set_event_color(obj, idx, color);
        
        obj  = set_sensor_labels(obj, idx, varargin);
        
        obj  = labels2numbers(obj);
        
        obj  = numbers2labels(obj);
        
        % Select/Deselect one among various overlying plots
        
        obj = select(obj, idx);
        
        obj = deselect(obj, idx);
        
        obj = set_overlay_colors(obj, value);
        
        % Accessors
        
        value = nb_plots(obj);
        
        value = get_figure(obj, varargin);
        
        value = get_axes(obj, varargin);
        
        value = get_line(obj, varargin);
        
        value = get_line_color(obj, varargin);
        
        value = get_scale(obj);
        
        value = get_scale_axes(obj, varargin);
        
        value = get_scale_label(obj, varargin);
        
        value = get_scale_num(obj, varargin);
        
        value = get_event_color(obj, idx);
        
        value = get_sensor_labels(obj, idx);
        
        value = get_overlay_colors(obj)
        
        value = get_selection(obj);
        
        function h     = get_handle(obj)
            h = obj.Figure;
        end
        
    end
    
    % Constructor
    methods
        
        function obj = eegplot(varargin)
            
            obj = obj@goo.abstract_configurable_handle(varargin{:});
            
        end
        
    end
    
    % Destructor
    methods
        
        function delete(obj)
            
            if get_config(obj, 'DeleteOnDestroy') ...
                    && ~isempty(obj.Figure) && ...
                    ishandle(obj.Figure) && obj.Figure > 0
                delete(obj.Figure);
            end
            
        end
        
    end
    
end