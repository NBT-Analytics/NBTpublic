classdef periodic_generator < physioset.event.generator & ...
        goo.abstract_setget
    % PERIODIC_GENERATOR - Generate periodic events
    %
    % See also: physioset.event
    
    methods (Static, Access = private)
        function fh = default_template()
            fh = @(sampl, idx, data) physioset.event.event(sampl, ...
                'Type', '_PeriodicEvent', 'Value', idx);
        end
    end
    
    
    properties
        
        FillData  = false; % Should the last epoch be extended to fill the data?
        StartTime = 0;    % In seconds from beginning of recording
        Period    = 10;   % In seconds
        Template  = physioset.event.periodic_generator.default_template;
        
    end
    
    methods
        
        % Consistency checks
        
        function obj = set.StartTime(obj, value)
            
            import exceptions.InvalidPropValue;
            
            if isempty(value),
                obj.StartTime = 0;
                return;
            end
            
            if ~isnumeric(value) || numel(value) ~= 1 || value < 0,
                throw(InvalidPropValue('StartTime', ...
                    'Must be a positive scalar'));
            end
            
            obj.StartTime = value;
            
        end
        
        function obj = set.Period(obj, value)
            
            import exceptions.InvalidPropValue;
            
            if isempty(value),
                obj.Period = 10;
                return;
            end
            
            if ~isnumeric(value) || numel(value) ~= 1 || value < 0,
                throw(InvalidPropValue('Period', ...
                    'Must be a positive scalar'));
            end
            
            obj.Period = value;
            
        end
        
        function obj = set.Template(obj, value)
            
            import exceptions.InvalidPropValue;
            import physioset.event.periodic_generator;
            
            if isempty(value),
                obj.Template = periodic_generator.default_template;
                return;
            end
            
            if ~isa(value, 'function_handle'),
                throw(InvalidPropValue('Template', ...
                    'Must be a function_handle'));
            end
            
            try
                toy = value(10, 1, physioset.physioset);
                if ~isa(toy, 'physioset.event.event'),
                    throw(InvalidPropValue('Template', ...
                        'Template must evaluate to an event object'));
                end
            catch ME
                if strcmp(ME.identifier, 'MATLAB:TooManyInputs'),
                    throw(InvalidPropValue('Template', ...
                        'Template must take three arguments'));
                else
                    rethrow(ME);
                end
            end
            
            obj.Template = value;
            
        end
        
        
        % physioset.event.generator interface
        
        function evArray = generate(obj, data, varargin)
            
            import physioset.event.event;
            
            period = ceil(obj.Period*data.SamplingRate);
            startTime = max(1, ceil(obj.StartTime*data.SamplingRate));
            
            sampl = startTime:period:size(data,2);
            
            if isempty(sampl),
                evArray = [];
                return;
            end
            
            evArray = obj.Template(sampl(1), 1, data);
            evArray = repmat(evArray, 1, numel(sampl));
            for i = 2:numel(sampl)
                evArray(i) = obj.Template(sampl(i), i, data);
            end
            
            % Ensure that no event exceeds the data duration
            for i = numel(evArray):-1:1
                onset_sample = get_sample(evArray(i));
                last_sample = onset_sample + get_duration(evArray(i)) - 1;
                if last_sample > size(data, 2),
                    available_samples = size(data, 2) - onset_sample + 1;
                    evArray(i) = set_duration(evArray(i), available_samples);
                else
                    break
                end
            end
            
            % If FillData ensure that the last sample of the last epoch is
            % the last sample of the dataset
            last_sample = get_sample(evArray(end)) + ...
                get_duration(evArray(end)) - 1;
            if obj.FillData && last_sample < size(data,2),
                missingSampl = size(data,2) - last_sample;
                evArray(end) = set_duration(evArray(end), ...
                    get_duration(evArray(end)) + missingSampl);
            end
        end
        
        % Constructor
        
        function obj = periodic_generator(varargin)
            
            import misc.process_arguments;
            import physioset.event.periodic_generator;
            
            opt.StartTime = 0;
            opt.Period    = 10;
            opt.Template  = [];
            opt.FillData = false;
            
            % We keep this for backwards compatibility
            opt.Type     = [];
            opt.Duration = [];
            opt.Offset   = [];
            
            [~, opt] = process_arguments(opt, varargin);
            
            if ~isempty(opt.Type) || ~isempty(opt.Duration) || ...
                    ~isempty(opt.Offset),             
                if ~isempty(opt.Template),
                    error(['Cannot use Template together with any of ' ...
                        'Type, Duration, Offset']);
                end
                
                opt.Type     =  '__PeriodicEvent';
                opt.Duration = 1;
                opt.Offset   = 0;
                [~, opt] = process_arguments(opt, varargin);
                opt.Template = @(sampl, idx, data) physioset.event.event(sampl, ...
                    'Type', opt.Type, 'Duration', ...
                    ceil(opt.Duration*data.SamplingRate), 'Offset', ...
                    round(opt.Offset*data.SamplingRate), 'Value', idx);
            else       
                if isempty(opt.Template),
                    opt.Template =  periodic_generator.default_template;
                end
            end
            obj.Template = opt.Template;
            obj.Period    = opt.Period;
            obj.StartTime = opt.StartTime;
            obj.FillData = opt.FillData;
        end
        
    end
    
end