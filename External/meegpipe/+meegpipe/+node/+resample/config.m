classdef config < meegpipe.node.abstract_config
    % CONFIG - Configuration for node resample
    %
    % ## Usage synopsis:
    %
    % % Create a resample node that resamples by 3/4
    % import meegpipe.node.resample.*;
    % myConfig = config('UpsampleBy', 3, 'DownsampleBy', 4);
    % myNode   = resample(myConfig);
    %
    % % Alternatively:
    % myNode = resample('UpsampleBy', 3, 'DownsampleBy', 4);
    %
    % ## Accepted configuration options (as key/value pairs):
    % 
    % * The detrend class admits all the key/value pairs admitted by the
    %   abstract_node class.
    %
    %       UpsampleBy  : Natural scalar. Default: 1
    %           Upsampling factor
    %               
    %       DownsampleBy : Natural scalar. Default: 1
    %           Downsampling factor
    %
    %       Antialiasing : Logical scalar. Default: true
    %           Use antialiasing filter
    %
    % See also: resample
   
    properties
        
        UpsampleBy   = 1;
        DownsampleBy = 1;
        OutputRate   = NaN;
        AutoDestroyMemMap = false;
        Antialiasing = true;
        
    end
    
    
    methods

        function obj = set.UpsampleBy(obj, value)
            import misc.isnatural;
            import exceptions.*;
            
            if numel(value) ~= 1 || ~isnatural(value),
                throw(InvalidPropValue('UpsampleBy', ...
                    'Must be a natural scalar'));
            end
            
            obj.UpsampleBy = value;

            
        end
        
        function obj = set.DownsampleBy(obj, value)
            import misc.isnatural;
            import exceptions.*;
            
            if numel(value) ~= 1 || ~isnatural(value),
                throw(InvalidPropValue('DownsampleBy', ...
                    'Must be a natural scalar'));
            end
            
            obj.DownsampleBy = value;
            
        end

        function obj = set.OutputRate(obj, value)

            import misc.isnatural;
            import exceptions.*;

            if numel(value) ~= 1 || (~isnatural(value) && ~isnan(value)),
                throw(InvalidPropValue('OutputRate', ...
                    'Must be a natural scalar or NaN'));
            end

            obj.OutputRate = value;
        end
        
    end
    
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@meegpipe.node.abstract_config(varargin{:});            

           
        end
        
    end
    
    
    
end