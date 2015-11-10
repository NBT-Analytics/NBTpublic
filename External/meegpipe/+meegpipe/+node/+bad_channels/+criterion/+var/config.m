classdef config < meegpipe.node.bad_channels.criterion.rank.config
    % CONFIG - Configuration for bad channels rejection criterion var
    %
    % See: <a href="matlab:misc.md_help('meegpipe.node.bad_channels.criterion.var.config')">misc.md_help(''meegpipe.node.bad_channels.criterion.var.config'')</a>
    
    
    properties
        NN              = 10;
        Filter          = [];
        Normalize       = true;
        LogScale        = true;
    end
    
    % Consistency checks
    methods
        
        function obj = set.NN(obj, value)
            
            import exceptions.*;
            import misc.isnatural;
            
            if isempty(value),
                value = 10;
            end
            
            if numel(value) > 1,
                throw(InvalidPropValue('NN', ...
                    'Must be a numeric scalar'));
            end
            
            obj.NN = ceil(value);
            
        end
        
        function obj = set.Filter(obj, value)
            
            import exceptions.*;
            
            if isempty(value),
                obj.Filter = [];
                return;
            end
            
            if ~isa(value, 'function_handle') && ...
                    ~isa(value, 'filter.dfilt'),
                throw(InvalidPropValue('Filter', ...
                    'Must be a filter.dfilt object'));
            end
            
            obj.Filter = value;
            
        end
        
        function obj = set.Normalize(obj, value)
            
            import exceptions.*;
            
            if isempty(value),
                % Default
                value = true;
            end
            
            if numel(value) ~= 1 || ~islogical(value),
                throw(InvalidPropValue('Normalize', ...
                    'Must be a logical scalar'));
            end
            
            obj.Normalize = value;
            
        end
        
        function obj = set.LogScale(obj, value)
            
            import exceptions.*;
            
            if isempty(value),
                % Default
                value = true;
            end
            
            if numel(value) ~= 1 || ~islogical(value),
                throw(InvalidPropValue('Normalize', ...
                    'Must be a logical scalar'));
            end
            
            obj.LogScale = value;
            
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
            
            opt.Min = @(x) median(x) - 20;
            opt.Max = @(x) median(x) + 4*mad(x);
            
            [~, opt] = process_arguments(opt, varargin);
            
            fNames = fieldnames(opt);
            for i = 1:numel(fNames)
                set(obj, fNames{i}, opt.(fNames{i}));
            end
            
        end
        
    end
    
    
    
end