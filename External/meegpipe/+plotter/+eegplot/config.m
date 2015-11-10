classdef config < goo.abstract_setget_handle
    % CONFIG - Configuration for class eegplot
    %
    % ## Usage synopsis:
    %
    % import plotter.eegplot.*;
    %
    % cfg   = config;
    % cfg   = config('key', value, ...);
    % cfg   = set(cfg, 'key', value, ...)
    % value = get(cfg, 'key');
    % 
    % % Create an eegplot object with a given configuration
    % myPlotter = eegplot(cfg); 
    %    
    %
    % ## Accepted configuration options (as key/value pairs):
    %
    %       SamplingRate: natural scalar. Default: 250
    %           Data sampling rate
    %
    % The following keys have the same meaning and take the same values as
    % the eponimous keys taken by EEGLAB's function eegplot. See help
    % eegplot for more information:
    %
    %       Spacing, Title, XGrid, YGrid, PlotEventDur, WinColor, Tag,
    %       Scale.
    %
    %
    % See also: eegplot

    
    %% PUBLIC INTERFACE ...................................................
    properties
        
        DeleteOnDestroy = true;
        SamplingRate    = 250;
        Spacing         = 0;    % 0=Use EEGLAB's default        
        Title           = '';
        XGrid           = 'off';
        YGrid           = 'off';
        PlotEventDur    = 'off';       
        WinColor        = [0.7 1 0.9];
        Tag             = '';
        Scale           = 'on';    
        Visible         = true;
  
    end
 
    % Consistency checks (set methods) to be done!
    
    % Constructor
    methods
        function obj = config(varargin)
            
            obj = obj@goo.abstract_setget_handle(varargin{:});
            
        end
        
    end
    
    
end