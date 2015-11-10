classdef config < meegpipe.node.abstract_config
    % CONFIG - Configuration of qrs_detect nodes
    %
    % See: <a href="matlab:misc.md_help('meegpipe.node.qrs_detect.config')">misc.md_help(''meegpipe.node.qrs_detect.config'')</a>
    
    
    properties
        
        Event      = @(sampl) physioset.event.std.qrs(sampl);
        Detector   = @(data) fmrib.my_fmrib_qrsdetect(data(:,:), ...
            data.SamplingRate, false);
        
    end
    
    % Consistency checks
    methods
        
        function obj = set.Event(obj, value)
            
            import exceptions.*;
            
            if isempty(value),
                value = @(sampl) physioset.event.std.qrs(sampl);
            end
            
            if numel(value) ~= 1 || (~isa(value, 'physioset.event.event') ...
                    && ~isa(value, 'function_handle')),
                throw(InvalidPropValue('Event', ...
                    'Must be an event object or a function_handle'));
            end
            
            if isa(value, 'function_handle'),
                try
                    toyEv = value(100);
                    if ~isa(toyEv, 'physioset.event.event'),
                        throw(InvalidPropValue('Event', ...
                            ['function_handle %s must evaluate to an ' ...
                            'event object'], char(value)));
                    end
                catch ME
                    throw(InvalidPropValue('Event', ...
                            ['function_handle %s must evaluate to an ' ...
                            'event object'], char(value)));
                end
            end
            
            
            obj.Event = value;
            
        end
        
        function obj = set.Detector(obj, value)
            
            import exceptions.InvalidPropValue;
            
            if numel(value) ~= 1 || ~isa(value, 'function_handle'),
                throw(InvalidPropValue('Detector', ...
                    'Must be a function_handle'));
            end
           
            obj.Detector = value;
            
        end
        
    end
    
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@meegpipe.node.abstract_config(varargin{:});
            
        end
        
    end
    
    
    
end