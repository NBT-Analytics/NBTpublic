classdef config < goo.abstract_setget_handle
    % CONFIG - Configuration for plotter.psd.psd
    %
    % ## Usage synopsis:
    %
    % cfg   = plotter.psd.config;
    % cfg   = plotter.psd.config('key', value, ...);
    % cfg   = set(cfg, 'key', value, ...)
    % value = get(cfg, 'key');
    %
    % % Create a plotter.psd object with a given configuration
    % myPlotter = plotter.psd(cfg);
    %
    %
    % ## Accepted configuration options (as key/value pairs):
    %
    %       Transparent: logical scalar. Default: false
    %           If set to true, the plotted PSDs will be transparent
    %
    %       ConfInt: logical scalar. Default: true
    %           If set to true, the confidence intervals of the PSDs will
    %           also be plotted (if such intervals have been computed when
    %           building the relevant dspdata.psd object).
    %
    %       ConfIntLegend: logical scalar. Default: true
    %           If set to false, the confidence intervals will not appear
    %           in the figure legend (even if the conf. intervals are
    %           available and have been plotted, i.e. even if ConfInt=true)
    %
    %       DeleteOnDestroy: logical scalar. Default: true
    %           If set to true, the figure associated with a plotter.psd
    %           handle will be deleted, after all references to the handled
    %           have been cleared from MATLAB's workspace.
    %
    %       FrequencyRange: 1x2 numeric vector. Default: [-Inf Inf]
    %           The frequency range to plot, in Hz
    %
    %       MatchScale : Kx2 numeric matrix. Default: []
    %           If not empty, the scales of the PSDs will be scaled in such
    %           a way that their power within the K bands specified by
    %           MatchScale is as similar as possible. MatchScale is
    %           specified in Hz. The first column are band starting points
    %           and the second column band end points.
    %
    %       BOI : An mjava.hash object. Default: mjava.hash
    %           Bands of Interest. A hash having as keys the name(s) of one
    %           more bands of interest and as values the corresponding band
    %           boundaries in Hz. For an example of how such hash may look
    %           like see the help of plotter.psd.eeg_bands.
    %
    %       Visible: logical scalar. Default: true
    %           Should the figure be visible? This option is useful when
    %           the figures are to be saved to a disk file instead of being
    %           inspected interactively.
    %
    %
    % See also: psd

    properties (SetObservable)
        
        Transparent     = false;    % Make plot transparent?
        PatchSaturation = 0.15;     % Patch Saturation
        ConfInt         = true;     % Plot confidence intervals?
        ConfIntLegend   = true;     % Should conf. int. appear in legend?
        FrequencyRange  = [-Inf Inf];
        MatchScale      = [];
        NormalizeScale  = false;        
        LogData         = true;
        Visible         = true;       
        BOI             = mjava.hash;
        
    end
    
    % Consistency checks (set methods)
    methods
        
    
        function set.Transparent(obj, value)
            
            import exceptions.*;
            
            if nargin < 2 || isempty(value),
                value = false;
            end
            if numel(value) ~= 1 || ~islogical(value),
                throw(InvalidPropValue('Transparent', ...
                    'A logical scalar was expected'));
            end
            obj.Transparent = value;
            
        end
        
        function set.ConfInt(obj, value)
            
            import exceptions.*;
            
            if nargin < 2 || isempty(value),
                value = false;
            end
            if numel(value) ~= 1 || ~islogical(value),
                throw(InvalidPropValue('ConfInt', ...
                    'A logical scalar was expected'));
            end
            obj.ConfInt = value;
            
        end
        
        function set.ConfIntLegend(obj, value)
            
            import exceptions.*;
            
            if nargin < 2 || isempty(value),
                value = false;
            end
            if numel(value) ~= 1 || ~islogical(value),
                throw(InvalidPropValue('ConfIntLegend', ...
                    'A logical scalar was expected'));
            end
            
            obj.ConfIntLegend = value;
            
        end
        
        function set.PatchSaturation(obj, value)
            
            import exceptions.*;
            
            if nargin < 2 || isempty(value),
                value = 0.15;
            end
            if numel(value) ~= 1 || ~isnumeric(value) || value < 0 ...
                    || value > 1,
                throw(InvalidPropValue('PatchSaturation', ...
                    'A numeric scalar between 0 and 1 was expected'));
            end
            obj.PatchSaturation = value;
            
        end
        
        function set.FrequencyRange(obj, value)
            
            import exceptions.*;
            
            if nargin < 2 || isempty(value),
                value = [-Inf Inf];
            end
            if any(size(value) ~= [1 2]) || ~isnumeric(value) || ...
                    value(1) > value(2),
                throw(InvalidPropValue('FrequencyRange', ...
                    'A valid frequency range was expected'));
            end
            obj.FrequencyRange = value;
            
        end
        
        function set.MatchScale(obj, value)
           
            import exceptions.*;
            import misc.ismatrix;
            
            if nargin < 2 || isempty(value),
                obj.MatchScale = [];
                return;
            end
            
            if size(value, 2) ~= 2 || ~ismatrix(value) || ~isnumeric(value)
                throw(InvalidPropValue('MatchScale', ...
                    'Must be a Kx2 numeric matrix'));
            end
            
            obj.MatchScale = value;
            
            
        end
        
        function set.LogData(obj, value)
            
            import exceptions.*;
            
            if nargin < 2 || isempty(value),
                value = false;
            end
            if numel(value) ~= 1 || ~islogical(value),
                throw(InvalidPropValue('LogData', ...
                    'A logical scalar was expected'));
            end
            obj.LogData = value;
            
        end
        
        function set.Visible(obj, value)
            
            import exceptions.*;
            
            if nargin < 2 || isempty(value),
                value = false;
            end
            if numel(value) ~= 1 || ~islogical(value),
                throw(InvalidPropValue('Visible', ...
                    'A logical scalar was expected'));
            end
            obj.Visible = value;
            
        end
        
    end
    
    
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@goo.abstract_setget_handle(varargin{:});
            
        end
        
    end
    
    
end