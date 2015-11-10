classdef psd < plotter.plotter & goo.abstract_configurable_handle
    % PSD - Plots Power Spectral Density estimates
    %
    %
    % ## Construction
    %
    % import plotter.psd.*;
    %
    % h = psd;
    % h = psd('key', value, ...)
    %
    % ## Accepted construction arguments (as key/value pairs):
    %
    %       * See: config
    %
    %
    % ## Usage synopsis:
    %
    % See help demo for a sample use case of this class.
    %
    %
    % See also: plotter.psd.config, plotter.psd.demo

   
    properties (GetAccess = private, SetAccess = private)
        
        Figure;     % Handle to the attached figure
        Axes;       % Handle to the plot axis
        Line;       % Handles to main plot lines and corresp. patches
        Name;       % Name associated with each line and patch
        Legend;     % Handles to the figure legend
        LegendProps;% User-defined legend properties        
        Data;       % An array of dspdata.psd objects   
        Frequencies;        
        
    end
    
    properties (Dependent)
       
        ConfigHandle_;
        
    end
    
    methods
       
        function val = get.ConfigHandle_(obj)
           
            val = get_config_handle(obj);
            
        end
        
    end
 
    methods (Access = private)      
        
        plot_conf(obj, psdObj, varargin);
        
        idx = resolve_idx(obj, idx);        
        
        % Listeners
        plot_legend(obj, src, evnt);
        
        set_transparency(obj, src, evnt);
        
        set_visibility(obj, src, evnt);
        
        set_confint(obj, src, evnt);
        
        set_freq_limits(obj, src, evnt);  
        
        set_matchscale(obj, src, evnt);  
        
    end   
    
    properties
       DeleteOnDestroy = true; 
    end
    
    properties (Dependent)
        PSDNames;              % Names of the plotted PSDs
    end
    
    methods
        function value = get.PSDNames(obj)
            if isempty(obj.Name),
                value = []; return;
            end
            value = obj.Name(:,1);
        end
    end    
    
    methods
       
        function obj = set.DeleteOnDestroy(obj, value)
            import exceptions.*;
            
            if isempty(value) || nargin < 2, return; end
            
            if numel(value)~=1 || ~islogical(value),
                throw(InvalidPropValue('DeleteOnDestroy', ...
                    'Must be a logical scalar'));
            end
            
            obj.DeleteOnDestroy = value;
        
        end
        
    end
   
    % plotter.plotter interface
    methods
        
        obj = clone(obj);
        
        obj = plot(obj, varargin);    
        
        obj = plot_dataset(obj, data, sr, estimator, varargin);
        
        obj = blackbg(obj, varargin);         
        
    end    
    
    % own methods
    methods
        
        % Modifiers
        
        obj = match_scale(obj, band);
        
        obj = orig_scale(obj);        
        
        obj = delete_psd(obj,   idx);
        
        obj = pop(obj);
        
        obj = set_psdname(obj,  idx, name);
        
        obj = set_line(obj,     idx, varargin);
        
        obj = set_edges(obj,    idx, varargin);
        
        obj = set_shadow(obj,   idx, varargin);
        
        obj = set_legend(obj,   varargin);
        
        obj = set_axes(obj,     varargin);
        
        obj = set_title(obj,    varargin);
        
        obj = set_xlabel(obj,   varargin);
        
        obj = set_ylabel(obj,   varargin);
        
        obj = set_boi(obj,      varargin);
        
        obj = rnd_line_colors(obj);        
        
        % Accessors
        
        value = get_line(obj,   idx, varargin);
        
        value = get_edges(obj,  idx, varargin);
        
        value = get_shadow(obj, idx, varargin);
        
        value = get_axes(obj, varargin);
        
        value = get_title(obj, varargin);
        
        value = get_xlabel(obj, varargin);
        
        value = get_ylabel(obj, varargin);
        
        value = get_legend(obj, varargin);        
        
        obj = legend(obj, varargin);
        
        ratios = band_power_ratio(obj);
        
        function h = get_handle(obj)
            h = obj.Figure;
        end
        
        
        
    end
    
    % Constructor
    methods
        
        function obj = psd(varargin)        
            
            import misc.split_arguments;
            import misc.process_arguments;
            
            thisProps = {'DeleteOnDestroy'};
            [thisArgs, varargin] = split_arguments(thisProps, varargin);
            
            opt.DeleteOnDestroy = true;
            [~, opt] = process_arguments(opt, thisArgs);
          
            obj = obj@goo.abstract_configurable_handle(varargin{:});
           
            % Add configuration listeners
            addlistener(obj.ConfigHandle_, 'Transparent',      'PostSet', ...
                @obj.set_transparency);
            
            addlistener(obj.ConfigHandle_, 'Visible',           'PostSet', ...
                @obj.set_visibility);
            
            addlistener(obj.ConfigHandle_, 'ConfInt',          'PostSet', ...
                @obj.set_confint);
            
            addlistener(obj.ConfigHandle_, 'ConfIntLegend',    'PostSet', ...
                @obj.plot_legend);
            
            addlistener(obj.ConfigHandle_, 'PatchSaturation',  'PostSet', ...
                @obj.set_transparency);
            
            addlistener(obj.ConfigHandle_, 'FrequencyRange',   'PostSet', ...
                @obj.set_freq_limits);
            
            addlistener(obj.ConfigHandle_, 'MatchScale',       'PostSet', ...
                @obj.set_matchscale);
            
            addlistener(obj.ConfigHandle_, 'NormalizeScale',   'PostSet', ...
                @obj.set_data_scale);
            
            addlistener(obj.ConfigHandle_, 'LogData',          'PostSet', ...
                @obj.set_data_scale);
            
            addlistener(obj.ConfigHandle_, 'BOI',              'PostSet', ...
                @obj.set_boi);
            
            % Ensure config is consistent with figure looks
            set_transparency(obj);
            set_visibility(obj);
            set_confint(obj);
            plot_legend(obj);
            set_freq_limits(obj);
            set_matchscale(obj);
            set_data_scale(obj);
            set_boi(obj);
            
            obj.DeleteOnDestroy = opt.DeleteOnDestroy;
            
        end
        
    end
    
    % Destructor
    methods
        
        function delete(obj)            
            
            if obj.DeleteOnDestroy && ...
                    ~isempty(obj.Figure) && ...
                    ishandle(obj.Figure) && ...
                    obj.Figure > 0           
                
                delete(obj.Figure);
               
            end
            
        end
        
    end
    
    
end