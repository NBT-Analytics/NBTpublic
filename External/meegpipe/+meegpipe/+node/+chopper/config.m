classdef config < meegpipe.node.abstract_config
    % CONFIG - Configuration for node chopper
    %
    % ## Usage synopsis:
    %
    % % Create a chopper node that will break the data using an index based
    % % on generalized eigenvalue decomposition:
    % import meegpipe.node.chopper.*;
    % myConfig = config('Algorithm', chopper.ged);
    % myNode   = chopper(myConfig);
    %
    % % Alternatively
    % myNode = chopper('Algorithm', chopper.ged);
    %
    % ## Accepted configuration options:
    %
    % * The bad_channels class constructor admits all the key/value pairs
    %   admitted by the abstract_node class.
    %
    %       Algorithm : A chopper.chopper object. Default: chopper.ged
    %           The chopping algorithm to use
    %
    %       Event : A physioset.event.event object. 
    %           Default: physioset.event.std.epoch_begin('Type', 'ChopBegin')
    %           The event class that will be used to mark the boundaries of
    %           each data chop.
    %
    % See also: chopper

    
    %% PUBLIC INTERFACE ...................................................
    
    properties
       
        Algorithm  = chopper.ged('MinChunkLength', ...
            @(data) data.SamplingRate*120);
        Event      = physioset.event.std.chop_begin;
        
    end
         
    % Consistency checks
    
    methods
       
        function obj = set.Algorithm(obj, value)
            
           import exceptions.*;
           
           if isempty(value), 
               value = chopper.ged('MinChunkLength', ...
                   @(data) data.SamplingRate*120);
           end
           
           if numel(value) ~= 1 || ~isa(value, 'chopper.chopper'),
               throw(InvalidPropValue('Algorithm', ...
                   'Must be a chopper.chopper object'));
           end
           
           obj.Algorithm = value;
            
        end
        
        function obj = set.Event(obj, value)
           
            import exceptions.*;
            
            if isempty(value),
                value =physioset.event.std.chop_begin;
            end
            
            if numel(value) ~= 1 || ~isa(value, 'physioset.event.event')
                throw(InvalidPropValue('Event', ...
                    'Must be a physioset.event.event object'));
            end
            
            obj.Event = value; 
            
        end
        
    end
    
     % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@meegpipe.node.abstract_config(varargin{:});
                        
        end
        
    end
    
    
end