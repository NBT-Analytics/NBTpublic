classdef config < meegpipe.node.abstract_config
    % CONFIG - Configuration for node chan_interp
    %
    % ## Usage synopsis:
    %
    %   % Create a channel interpolation node that will interpolate bad
    %   % channels using a weighted average of the 5 nearest neighbor
    %   % channels
    %   import meegpipe.node.chan_interp.*;
    %   myCfg  = criterion.chan_interp.config('NN', 5);
    %   myNode = chan_interp('Config', myCfg);
    %
    %   % Or you could do directly:
    %   myNode = chan_interp('NN', 5);
    %
    % ## Accepted configuration options (as key/value pairs):
    %
    % * The bad_channels class constructor admits all the key/value pairs
    %   admitted by the abstract_node class.
    %
    %       NN : A natural scalar. Default: 4          
    %           The number of nearest neighbors to use for the
    %           interpolation process.
    %
    %       ClearBadChannels : A logical scalar. Default: false
    %           If set to true, all interpolated bad channels will become
    %           "good", i.e. they will not be anymore be flagged as bad
    %           channels. 
    %
    %
    % See also: bad_epochs, abstract_node
    
   
    properties
        
        NN = 4;
        ClearBadChannels = false;
        
    end
    
    % Consistency checks
    methods
       
        function obj = set.NN(obj, value)          
            import exceptions.InvalidPropValue;
            import misc.isnatural;
            if isempty(value),
                % Set to default
                value = 4;
            end           
            if numel(value) ~= 1 || ~isnatural(value),
                throw(InvalidPropValue('NN', ...
                    'Must be a natural scalar'));
            end 
            obj.NN = value;   
        end    
        function obj = set.ClearBadChannels(obj, value)          
            import exceptions.InvalidPropValue;
            if isempty(value),
                % Set to default
                value = false;
            end           
            if numel(value) ~= 1 || ~islogical(value),
                throw(InvalidPropValue('ClearBadChannels', ...
                    'Must be a logical scalar'));
            end 
            obj.ClearBadChannels = value;   
        end    
        
    end
    
    
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@meegpipe.node.abstract_config(varargin{:});
                        
        end
        
    end
    
    
    
end