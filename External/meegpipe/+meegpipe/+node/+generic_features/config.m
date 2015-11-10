classdef config < meegpipe.node.abstract_config
    % CONFIG - Configuration of erp nodes
    %
    % See: <a href="matlab:misc.md_help('meegpipe.node.erp.config')">misc.md_help(''meegpipe.node.erp.config'')</a>
    
    
    properties
        
        TargetSelector    = {pset.selector.all_data};
        FirstLevel        = {@(x, ev, dataSel) mean(x)};
        SecondLevel       = [];
        FeatureNames      = {'mean'};
        % These Auxiliary vars will be computed only once and passed as
        % arguments to all FirstLevel feature extractors. This can speed up
        % considerably the computation of the features when all feature
        % extractors share some preliminary steps.
        AuxVars           = {}; 
        Plotter = {physioset.plotter.snapshots.snapshots('WinLength', 20)};
        
    end
    
    % Consistency checks
    
    methods (Access = private)
        
        function global_check(obj)
            import exceptions.Inconsistent;
            
            if isempty(obj.SecondLevel),
                if numel(obj.FeatureNames) ~= numel(obj.FirstLevel),
                    
                    throw(Inconsistent(['Number of feature names does not ' ...
                        'match number of first level features']));
                    
                end
                
            elseif ~isempty(obj.SecondLevel)
                
                if numel(obj.FeatureNames) ~= numel(obj.SecondLevel),
                    
                    throw(Inconsistent(sprintf([...
                        'Property FeatureNames must have dimensions ' ...
                        '[%d %d]'], numel(obj.FirstLevel), ...
                        numel(obj.SecondLevel))));
                    
                end
                
            end
            
        end
        
    end
    
    methods
        
        function obj = set.Plotter(obj, value)
            
            import exceptions.InvalidPropValue;
            
            if isempty(value), value = {}; end 
            
            if ~iscell(value),
                value = {value};
            end
            
            if ~all(cellfun(@(x) isa(x, 'report.gallery_plotter'), value)),
                throw(InvalidPropValue('Plotter', ...
                    'Must be a cell array of gallery_plotter objects'));
            end
           
            obj.Plotter = value;
        end
        
        function obj = set.TargetSelector(obj, value)
            
            import exceptions.InvalidPropValue;
            
            if isempty(value),
                obj.TargetSelector = {pset.selector.all_data};
                return;
            end
            
            if ~iscell(value), value = {value}; end
            
            if ~all(cellfun(@(x) isa(x, 'pset.selector.selector'), value))
                throw(InvalidPropValue('TargetSelector', ...
                    'Must be a data selector object'));
            end
            
            obj.TargetSelector = value;
            
        end
        
        function obj = set.FirstLevel(obj, value)
            import exceptions.InvalidPropValue;
            
            if isempty(value),
                obj.FirstLevel = [];
                return;
            end
            
            if ~iscell(value), value = {value}; end
            
            if ~all(cellfun(@(x) isa(x, 'function_handle'), value))
                throw(InvalidPropValue('FirstLevel', ...
                    'Must be a cell array of function_handle'));
            end
            
            obj.FirstLevel = value;
        end
        
        function obj = set.SecondLevel(obj, value)
            import exceptions.InvalidPropValue;
            if isempty(value),
                obj.SecondLevel = [];
                return;
            end
            
            if ~iscell(value), value = {value}; end
            
            if ~all(cellfun(@(x) isa(x, 'function_handle'), value))
                throw(InvalidPropValue('SecondLevel', ...
                    'Must be a cell array of function_handle'));
            end
            
            obj.SecondLevel = value;
        end
        
    end
    
    % Constructor
    methods
        
        function obj = config(varargin)
            
            % Translate FeatureDescriptors -> FirstLevel, for backwards
            % compatibility
            if nargin > 1,
                for i = 1:2:nargin
                   if ismember(lower(varargin{i}), ...
                           {'featuredescriptors', 'featuredescriptor'}), 
                       varargin{i} = 'FirstLevel';
                   end
                end
            end
            
            obj = obj@meegpipe.node.abstract_config(varargin{:});
            
            global_check(obj);
            
        end
        
    end
    
    
end