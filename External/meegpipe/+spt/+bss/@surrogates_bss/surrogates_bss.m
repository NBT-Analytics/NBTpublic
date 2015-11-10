classdef surrogates_bss < spt.abstract_spt
    % SURROGATES_BSS - Centroid BSS from a set of surrogate datasets
    
    properties (SetAccess = private, GetAccess = private)
        BSSSurr;
        CentroidDistance;
        CentroidIdx;
    end
    
    properties
        BSS          = {spt.bss.jade};
        DistMeas     = @(obj1, obj2, data) ...
            spt.amari_index(projmat(obj1)*bprojmat(obj2), 'range', [0 100]);
        Surrogator   = surrogates.shuffle('NbPoints', 500000);
        NbSurrogates = 20;
        DistAggregator = @(dist) prctile(dist, 10);
    end
    
    methods
        
        function obj = set.BSS(obj, value)
            import exceptions.InvalidPropValue;
            
            if isempty(value),
                obj.BSS = {spt.bss.jade};
                return;
            end
            
            if ~iscell(value),
                value = {value};
            end
            
            if ~all(cellfun(@(x) isa(x, 'spt.spt'), value))
                throw(InvalidPropValue('BSS', ...
                    'Must be a cell array of spt.spt objects'));
            end
            obj.BSS = value;
            
        end
        
        function obj = set.Surrogator(obj, value)
            import exceptions.InvalidPropValue;
            
            if isempty(value),
                obj.Surrogator = surrogates.shuffle('NbPoints', 500000);
                return;
            end
            
            if ~isa(value, 'surrogates.surrogator'),
                throw(InvalidPropValue('Surrogator', ...
                    'Must be a surrogates.surrogator object'));
            end
            obj.Surrogator = value;
        end
    end
    
    methods
        % Declared (but not defined) by abstract_spt
        obj = learn_basis(obj, data, varargin);
        
        % Redefinitions
        function W = projmat(obj, varargin)
            import exceptions.NeedsLearning;
            
            centroid = get_centroid_bss(obj);
            
            if isempty(centroid),
                throw(NeedsLearning('Did you forget to run learn()?'));
            end
            
            W = projmat(centroid, varargin{:});
        end
        
        function A = bprojmat(obj, varargin)
            import exceptions.NeedsLearning;
            
            centroid = get_centroid_bss(obj);
            
            if isempty(centroid),
                throw(NeedsLearning('Did you forget to run learn()?'));
            end
            A = bprojmat(centroid, varargin{:});
        end
        
        % Declared and defined here
        function bndry = get_centroid_distance(obj)
            bndry = obj.CentroidDistance;
        end
        
        function bssArray = get_bss_surrogates(obj)
            bssArray = obj.BSSSurr;
        end
        
        function bss = get_centroid_bss(obj)
            bss = obj.BSSSurr{obj.CentroidIdx};
        end
        
        % Constructor
        function obj = surrogates_bss(varargin)
            
            import misc.set_properties;
            import misc.split_arguments;
            
            % Pick the BSS algorithm
            if nargin > 0,
                count = 1;
                while isa(varargin{count}, 'spt.spt'),
                    count = count + 1;
                end
                if count > 1,
                    varargin = ...
                        [{'BSS'}, {varargin(1:count-1)} varargin(count:end)];
                end
            end
            opt.BSS          = {spt.bss.jade};
            opt.DistMeas     = @(obj1, obj2, data) ...
                spt.amari_index(projmat(obj1)*bprojmat(obj2), 'range', [0 100]);
            opt.Surrogator   = surrogates.shuffle('NbPoints', 500000);
            opt.NbSurrogates = 20;
            [thisArgs, argsParent] = split_arguments(fieldnames(opt), varargin);
            
            obj = obj@spt.abstract_spt(argsParent{:});
            
            obj = set_properties(obj, opt, thisArgs);
        end
        
    end
    
end