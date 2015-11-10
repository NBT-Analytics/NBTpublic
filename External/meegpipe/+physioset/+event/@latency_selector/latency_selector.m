classdef latency_selector < ...
        physioset.event.selector & ...
        goo.abstract_setget
    % LATENCY_SELECTOR - Class that selects events within certain latency range
    %
    % import physioset.event.*;
    % mySelector = latency_selector(sr, latRange);
    % mySelector = latency_selector(sr, latRange, 'key', value, ...)
    %
    % Where
    %
    % SR is the data sampling rate.
    %
    % LATRANGE is the latency_selector range for which events should be extracted
    % using method select().
    %
    % ## Optional arguments (as key/value pairs):
    %
    %       ResetStartLatency: Logical scalar. Default: true
    %           If set to true, the selected events will be modified in
    %           such a way that the beginning point of the LatencyRange
    %           property will be the new zero latency. That is, all event 
    %           latencies will be shifted backwards LatencyRange(1) seconds
    %
    % See also: event, physioset, selector

    % PUBLIC INTERFACE ....................................................
    properties
        
        SamplingRate      = [];
        LatencyRange      = [];
        ResetStartLatency = true;
        Negated           = false;
        
    end
    
    methods
        
        function obj = set.LatencyRange(obj, value)
            
            import exceptions.*
            
            if isempty(value) || ~isnumeric(value) || size(value, 2) ~= 2 ...
                    || any(diff(value, [], 2) < 0),
                throw(InvalidPropValue('LatencyRange', ...
                    'Must be a Kx2 vector with latency_selector range(s)'));
            end
            
            obj.LatencyRange = value;
        end
        
        function obj = set.SamplingRate(obj, value)
            
            import eegpipe.exception.*;
            import misc.isnatural;
            import exceptions.*
            
            if isempty(value) || ~isnatural(value),
                throw(InvalidPropValue('SamplingRate', ...
                    'Must be a natural scalar'));
            end
            
            obj.SamplingRate = value;
            
        end
        
        function obj = set.ResetStartLatency(obj, value)
            
            import exceptions.*
            
            if numel(obj) ~= 1 || ~islogical(value),
                throw(InvalidPropValue('ResetLatencyRange', ...
                    'Must be a logical scalar'));
            end
            
            obj.ResetStartLatency = value;
            
        end
        
        function obj = set.Negated(obj, value)
            import exceptions.*;
            
            if numel(value) ~= 1 || ~islogical(value),
                throw(InvalidPropValue('Negated', ...
                    'Must be a logical scalar'));
            end
            obj.Negated = value;
            
        end
        
    end
    
    % physioset.event.selector.selector interface
    methods
        
        function obj = not(obj)
            
            obj.Negated = ~obj.Negated;
            
        end
        
        [evArray, idx] = select(obj, evArray)
        
    end
    
    % Constructor
    methods
        
        function obj = latency_selector(sr, latencyRange, varargin)
            
            import exceptions.*
            
            if nargin < 1, return; end
            
            if nargin < 2,
                throw(InvalidPropValue('LatencyRange', ...
                    'A latency_selector range must be provided'));
            end
            
            obj.SamplingRate = sr;
            obj.LatencyRange = latencyRange;
            
            obj = set(obj, varargin{:});
            
        end
        
    end
    
end