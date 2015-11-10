classdef config < meegpipe.node.bad_epochs.criterion.rank.config
    % CONFIG - Configuration for bad epochs rejection criterion stat
    %
    % See: <a href="matlab:misc.md_help('meegpipe.node.bad_epochs.criterion.stat.config')">misc.md_help(''meegpipe.node.bad_epochs.criterion.stat.config'')</a>
   
    properties
        
        ChannelStat = meegpipe.node.bad_epochs.criterion.stat.config.default('ChannelStat'); 
        EpochStat   = meegpipe.node.bad_epochs.criterion.stat.config.default('EpochStat'); 
        
    end
    
    % property defaults
    methods (Static, Access = private)
        function val = default(pName)
           switch lower(pName),
               case 'channelstat',
                   val = @(x) max(abs(x));
               case 'epochstat',
                   val = @(x) prctile(x, 75);
               otherwise
                   error('Invalid configuration option: %s', pName);
           end
        end
    end

    methods
        % Consistency checks
        function obj = set.ChannelStat(obj, value)
           import exceptions.InvalidPropValue;
           import meegpipe.node.bad_epochs.criterion.stat.config;
           
           if isempty(value),
               obj.ChannelStat = config.default('ChannelStat'); 
               return;
           end
           
           if numel(value) ~= 1 || ...
                   (~isnumeric(value) && ~isa(value, 'function_handle')),
               throw(InvalidPropValue('ChannelStat', ...
                   'Must be a numeric scalar or function_handle'));
           end
           
           if isa(value, 'function_handle'),
               testVal = value(1:100);
               if numel(testVal) ~= 1 || ~isnumeric(testVal),
                   throw(InvalidPropValue('ChannelStat', ...
                   ['function_handle must take one vector argument and ' ...
                   'evaluate to a scalar']));
               end
           end
           
           obj.ChannelStat = value;            
        end
        
        function obj = set.EpochStat(obj, value)
           import exceptions.InvalidPropValue;
           import meegpipe.node.bad_epochs.criterion.stat.config;
           
           if isempty(value),
               obj.EpochStat = config.default('EpochStat'); 
               return;
           end
           
           if numel(value) ~= 1 || ...
                   (~isnumeric(value) && ~isa(value, 'function_handle')),
               throw(InvalidPropValue('EpochStat', ...
                   'Must be a numeric scalar or function_handle'));
           end
           
           if isa(value, 'function_handle'),
               testVal = value(1:100);
               if numel(testVal) ~= 1 || ~isnumeric(testVal),
                   throw(InvalidPropValue('EpochStat', ...
                   ['function_handle must take one vector argument and ' ...
                   'evaluate to a scalar']));
               end
           end
           
           obj.EpochStat = value;            
        end
        
        % Constructor
        function obj = config(varargin)
            obj = obj@meegpipe.node.bad_epochs.criterion.rank.config(varargin{:});       
        end
        
    end
    
    
    
end