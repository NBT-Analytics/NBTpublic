classdef snapshots < report.abstract_gallery_plotter
    % SNAPSHOTS - Plots physioset snapshots
    %
    % ## Usage synopsis
    %
    %   import pset.plotter.snapshots.*;
    %
    %   % Define the plotted windows to be 10 seconds long
    %   myConfig = config('WinLength', 10);
    %
    %   % Build the plotter object
    %   myPlotter = snapshots(myConfig);
    %
    %   % Alternatively, you could have done this:
    %   myPlotter = snapshots('WinLength', 10);
    %
    %   % Or this
    %   myPlotter = snapshots; % Default object
    %   myPlotter = set_config(myPlotter, 'WinLength', 10);
    %
    %   % Import some sample data and plot it
    %   myData = import(physioset.import.matrix, randn(250, 10000))
    %
    %   % Do the plotting...
    %   plot(myPlotter, myData);
    %
    %
    % ## Notes:
    %
    %   * See the help of class config in package pset.plotter.snapshots for
    %     information of available plotter configuration options.
    %
    %   * By default, the generated figure files are stored in the current
    %     session folder. If no session has been created, creation of a
    %     snapshots object will create a new session. You can modify the
    %     default folder settings like this:
    %
    %     myPlotter = set_config(myPlotter, 'Folder', somePath);
    %
    %
    % See also: config, demo, make_test

    methods (Static, Access = private)
        [epochs, groupNames] = summary_epochs(epochLength, nbPoints, winrej, config);
    end
 
    methods
        
        % report.gallery_plotter interface
        [h, groups, cap, extra, extraCap, cfg] = plot(obj, data, varargin);
        
        % report.reportable interface
        [pName, pValue, pDescr]   = report_info(obj, varargin);
        
        
    end
    
    % Constructor
    methods
        function obj = snapshots(varargin)
            
            obj = obj@report.abstract_gallery_plotter(varargin{:});
            
        end
    end
    
    
end