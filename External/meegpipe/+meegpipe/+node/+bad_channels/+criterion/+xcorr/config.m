classdef config < meegpipe.node.bad_channels.criterion.rank.config
    % This config class is not intended to be used directly. It implements
    % consistency checks required for the construction of a valid
    % meegpipe.node.bad_channels.criterion.var.var object. The
    % configuration options listed below can be passed as key/value
    % arguments during the construction of a xcorr criterion object.
    %
    % ## Usage synopsis:
    %
    % % Create a bad_samples node that will reject all channels whose
    % % variance is not within 20 median absolute deviations of the median
    % % channel variance.
    % import meegpipe.node.bad_channels.criterion.xcorr.config;
    % import meegpipe.node.bad_channels.criterion.xcorr.xcorr;
    % myConfig = config('NN', 10);
    % myCrit   = xcorr(myConfig);
    %
    % % Alternatively:
    % myCrit = xcorr('NN', 10);
    %
    % % Once the criterion has been constructed, you can feed it to the
    % % constructor of a bad_channels node:
    % import meegpipe.node.bad_channels.bad_channels;
    % myNode = bad_channels('Criterion', myCrit);
    %
    %
    % ## Accepted configuration options (as key/value pairs):
    %
    % * The xcorr criterion constructor admits all the key/value pairs
    %   admitted by the rank criterion constructor. See:
    %   help meegpipe.node.bad_channels.criterion.rank.config
    %
    %
    %       NN : Numeric scalar. Default: 10
    %           Number of nearest neighbor sensors to consider when
    %           calculating local data variances.
    %
    % See also: xcorr, bad_channels, abstract_node
    
    
    properties
        
        NN = 10;
        
    end
    
    % Consistency checks
    methods
        
        
        function obj = set.NN(obj, value)
            
            import exceptions.*;
            import misc.isnatural;
            
            if isempty(value),
                value = 10;
            end
            
            if ~isnatural(value) || numel(value) > 1,
                throw(InvalidPropValue('Weights', ...
                    'Must be a natural scalar'));
            end
            
            obj.NN = value;
            
        end
        
        
    end
    
    
    % Constructor
    methods
        
        function obj = config(varargin)
            import misc.process_arguments;
            
            obj = obj@meegpipe.node.bad_channels.criterion.rank.config(...
                varargin{:});
            
            if nargin == 1,
                % Copy constructor!
                return;
            end
            
            opt.Min = @(r) prctile(r, 1);
            opt.Max = Inf;
            
            [~, opt] = process_arguments(opt, varargin);
            
            fNames = fieldnames(opt);
            for i = 1:numel(fNames)
                set(obj, fNames{i}, opt.(fNames{i}));
            end
            
        end
        
    end
    
    
    
end