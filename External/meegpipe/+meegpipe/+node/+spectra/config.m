classdef config < meegpipe.node.abstract_config
    % CONFIG - Configuration of spectra nodes
    %
    % See: <a href="matlab:misc.md_help('meegpipe.node.spectra.config')">misc.md_help(''meegpipe.node.spectra.config'')</a>
    
    
    
    properties
        
        EventSelector  = [];
        Offset         = [];
        Duration       = [];
        Estimator      = ...
            @(fs)spectrum2.percentile('Estimator', ...
            spectrum.welch('Hamming', fs*3));
        Channels       = @(data) labels(sensors(data));
        Channels2Plot  = [];  % The channel sets to plot
        ROI            = meegpipe.node.spectra.eeg_bands;
        Normalized     = true;
        PlotterPSD     = @(sr) plotter.psd.psd(...
            'FrequencyRange', [0 min(100, sr/3)], ...
            'LogData',        false);
        PlotterTopo    = plotter.topography.new('Visible', false, ...
            'MapLimits', 'maxmin');
        
    end
    
    % Consistency checks
    
    methods
        
        function obj = set.EventSelector(obj, value)
            
            import exceptions.*;
            
            if isempty(value),
                obj.EventSelector = [];
                return;
            end
            
            if numel(value) ~= 1 || ...
                    ~isa(value, 'physioset.event.selector'),
                throw(InvalidPropValue('EventSelector', ...
                    'Must be a physioset.event.selector object'));
            end
            
            obj.EventSelector = value;
            
        end
        
        function obj = set.Offset(obj, value)
            
            import exceptions.*;
            
            if isempty(value),
                obj.Offset = [];
                return;
            end
            
            if numel(value) ~= 1 || ~isnumeric(value)
                throw(InvalidPropValue('Offset', ...
                    'Must be a numeric scalar'));
            end
            
            obj.Offset = value;
            
        end
        
        function obj = set.Duration(obj, value)
            
            import exceptions.*;
            
            if isempty(value),
                obj.Duration = [];
                return;
            end
            
            if numel(value) ~= 1 || ~isnumeric(value)
                throw(InvalidPropValue('Duration', ...
                    'Must be a numeric scalar'));
            end
            
            obj.Duration = value;
            
        end
        
        function obj = set.Estimator(obj, value)
            
            import exceptions.InvalidPropValue;
            
            if isempty(value),
                value = @(fs) spectrum.welch('Hamming', 2*fs); %#ok<*PDEPR>
            end
            
            if numel(value) ~= 1 || (~isa(value, 'function_handle') && ...
                    isempty(regexp(class(value), '^spectrum\..+', 'once'))),
                
                throw(InvalidPropValue('Estimator', ...
                    'Must be a spectrum.* object'));
                
            end
            
            if isa(value, 'function_handle'),
                try
                    testVal = value(1000);
                catch ME
                    throw(InvalidPropValue('Estimator', ...
                        ['function_handle must take sampling rate as ' ...
                        'input argument']));
                end
                
                if isempty(regexp(class(testVal), '^spectrum\d?\..+', 'once')),
                    throw(InvalidPropValue('Estimator', ...
                        ['function_handle must evaluate to a ' ...
                        'spectrum.* object']));
                end
            end
            
            
            obj.Estimator = value;
            
            
        end
        
        function obj = set.Channels(obj, value)
            
            import exceptions.*;
            import meegpipe.node.spectra.config;
            
            if isempty(value),
                obj.Channels = @(data) labels(sensors(data));;
                return;
            end
            
            if ischar(value),
                value = {value};
            end
            
            ME = InvalidPropValue('Channels', ...
                ['Must be a cell array of '  ...
                'strings/cellarrays/function_handles or a regex']);            
          
            obj.Channels = value;
            
        end
        
        function obj = set.Channels2Plot(obj, value)
            
            import exceptions.InvalidPropValue;
            
            if isempty(value),
                obj.Channels2Plot = [];
                return;
            end
          
            obj.Channels2Plot = value;
            
        end
        
        
        function obj = set.ROI(obj, value)
            
            import exceptions.InvalidPropValue;
            
            if isempty(value),
                obj.ROI = [];
                return;
            end
            
            if ~isa(value, 'mjava.hash'),
                throw(InvalidPropValue('ROI', ...
                    'Must be an mjava.hash object'));
            end
            
            keyStr = keys(value);
            
            if isempty(keyStr),
                obj.ROI = [];
                return;
            end
            
            for i = 1:numel(keyStr)
                val = value(keyStr{i});
                
                if isnumeric(val) && numel(val) == 2,
                    value(keyStr{i}) = {val};
                    val = {val};
                end
                
                if ~iscell(val) || ~isnumeric(val{1}) || numel(val{1}) < 2,
                    throw(InvalidPropValue('ROI', ...
                        ['Hash values must be 1x2 cell arrays of 1x2 ' ...
                        'vectors']));
                end
                
            end
            
            obj.ROI = value;
            
        end
        
        function obj = set.Normalized(obj, value)
            
            import exceptions.InvalidPropValue;
            
            if isempty(value),
                obj.Normalized = true;
                return;
            end
            
            if numel(value) ~= 1 || ~islogical(value),
                throw(InvalidPropValue('Normalized', ...
                    'Must be a logical scalar'));
            end
            
            obj.Normalized = value;
            
        end
        
        function obj = set.PlotterPSD(obj, value)
            
            import exceptions.InvalidPropValue;
            
            if isempty(value),
                obj.PlotterPSD = ...
                    @(sr) plotter.psd.psd('FrequencyRange', [0 min(60, sr/4)]);
                return;
            end
            
            if ~isa(value, 'function_handle') && ...
                    ~isa(value, 'plotter.plotter')
                throw(InvalidPropValue('PlotterPSD', ...
                    'Must be a plotter.plotter object'));
            end
            
            obj.PlotterPSD = value;
            
        end
        
        function obj = set.PlotterTopo(obj, value)
            
            import exceptions.InvalidPropValue;
            
            if isempty(value),
                obj.PlotterTopo = plotter.topography.new('Visible', false, ...
                    'MapLimits', 'maxmin');
                return;
            end
            
            if ~isa(value, 'function_handle') && ...
                    ~isa(value, 'plotter.plotter')
                throw(InvalidPropValue('PlotterTopo', ...
                    'Must be a report.abstract_gallery_plotter object'));
            end
            
            obj.PlotterTopo = value;
            
        end
        
    end
 
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@meegpipe.node.abstract_config(varargin{:});
            
        end
        
    end
    
    
end