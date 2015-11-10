classdef config < meegpipe.node.abstract_config
    % CONFIG - Configuration bss node
    properties
        PCA             = spt.pca(  'Criterion',  'none', ...
                                    'RetainedVar', 99.99, ...
                                    'MaxCard', 50);
        BSS             = spt.bss.multicombi;
        RegrFilter      = [];
        Criterion       = spt.criterion.dummy;
        Reject          = true;
        Filter          = [];
        Feature         = [];
        FeatureTarget   = 'selected'; % or 'all'
        SnapshotPlotter = meegpipe.node.bss.default_snapshot_plotter;
        TopoPlotter     = meegpipe.node.bss.default_topo_plotter;
        PSDPlotter      = meegpipe.node.bss.default_psd_plotter;
        SaveActivations = true;
    end

    methods
        % Consistency checks
        function obj = set.FeatureTarget(obj, value)
            import exceptions.InvalidPropValue;
            if isempty(value),
                obj.FeatureTarget = 'selected';
                return;
            end
            if ~ischar(value) || ~ismember(value, {'all', 'selected'}),
                throw(InvalidPropValue('FeatureTarget', ...
                    'Must be ''all'' or ''selected'''));
            end
            obj.FeatureTarget = value;
        end

        function obj = set.Feature(obj, value)
            import exceptions.InvalidPropValue;
            if isempty(value),
                obj.Feature = [];
                return;
            end
            if ~iscell(value), value = {value}; end
            if ~all(cellfun(@(x) isa(x, 'spt.feature.feature'), value)),
                throw(InvalidPropValue('Feature', ...
                    'Must be a (cell array of) spt.feature.feature object(s)'));
            end
            obj.Feature = value;
        end

        function obj = set.SnapshotPlotter(obj, value)
            import exceptions.InvalidPropValue;
            if isempty(value),
                obj.SnapshotPlotter = ...
                    meegpipe.node.bss.default_snapshot_plotter;
                return;
            end
            if numel(value) ~= 1 || ~isa(value, 'report.gallery_plotter'),
                throw(InvalidPropValue('SnapshotPlotter', ...
                    'Must be a report.gallery_plotter'));
            end
            obj.SnapshotPlotter = value;
        end

        function obj = set.RegrFilter(obj, value)
            import exceptions.*;
            if isempty(value) || ...
                    (isnumeric(value) && numel(value) == 1 && isnan(value)),
                obj.RegrFilter = [];
                return;
            end
            if ~isa(value, 'filter.rfilt'),
                throw(InvalidPropValue('Filter', ...
                    'Must be a filter.rfilt objects'));
            end
            obj.RegrFilter = value;
        end

        function obj = set.Criterion(obj, value)
            import exceptions.*;
            if isempty(value),
                obj.Criterion = spt.criterion.dummy;
                return;
            end
            if ~isa(value, 'spt.criterion.criterion'),
                throw(InvalidPropValue('Criterion', ...
                    'Must be a spt.criterion.criterion object'));
            end
            obj.Criterion = value;
        end

        function obj = set.PCA(obj, value)
            import exceptions.*;
            if isempty(value),
                obj.PCA = spt.pca('Criterion', 'none', ...
                    'RetainedVar', 99.99, 'MaxCard', 50);
                return;
            end
            if ~isa(value, 'spt.pca'),
                throw(InvalidPropValue('PCA', ...
                    'Must be a spt.pca object'));
            end
            obj.PCA = value;
        end

        function obj = set.BSS(obj, value)
            import exceptions.*;
            if isempty(value),
                obj.BSS = spt.bss.multicombi;
                return;
            end
            if ~isa(value, 'spt.spt'),
                throw(InvalidPropValue('BSS', ...
                    'Must be a spt.spt object'));
            end
            obj.BSS = value;
        end

        % Constructor
        function obj = config(varargin)
            obj = obj@meegpipe.node.abstract_config(varargin{:});
        end
    end
end