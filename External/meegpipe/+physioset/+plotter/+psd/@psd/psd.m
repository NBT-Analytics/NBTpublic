classdef psd < report.abstract_gallery_plotter
    % PSD - Plots Power Spectral Densities from a physioset
    %
    % ## Usage synopsis:
    %
    %   import pset.plotter.psd.*;
    %
    %   % Define the properties of the PSD estimator
    %   myEstimator = spectrum.welch('Hamming', 2000);
    %   myConfig    = config('Estimator', myEstimator);
    %
    %   % Build the plotter object
    %   myPlotter = psd(myConfig);
    %
    %   % Alternatively, you could have done this:
    %   myPlotter = psd('Estimator', myEstimator);
    %
    %   % Or this:
    %   myPlotter = psd; % Default constructor
    %   myPlotter = set_config(myPlotter, 'Estimator', myEstimator);
    %
    %   % Import some data and plot it
    %   myData = import(physioset.import.matrix, randn(250, 10000));
    %   plot(myPlotter, myData);
    %
    %
    % ## Notes:
    %
    %   * See the help of the config class for information of available
    %     configuration options.
    %
    % See also: config, demo
    
    
    %% PUBLIC INTERFACE....................................................
    
    methods
        
        % report.gallery_plotter interface
        [h, groups, captions, extra, extraCap] = plot(obj, data, varargin);
        
        % report.reportable interface
        [pName, pValue, pDescr]   = report_info(obj, varargin);
        
    end
    
    % Constructor
    methods
        
        function obj = psd(varargin)
            
            obj = obj@report.abstract_gallery_plotter(varargin{:});
            
        end
        
    end
    
    
end