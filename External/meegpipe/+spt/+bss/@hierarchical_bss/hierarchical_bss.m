classdef hierarchical_bss < spt.abstract_spt
    
    methods (Access = private)
        
        [bssArray, winBndry] = learn_lr_basis(obj, data, bssCentroid, winBndry);
        
    end
    
    properties (SetAccess = private, GetAccess = private)
        WinBoundary = [];
        BSSwin      = {};
    end
    
    properties
        BSS                = spt.bss.jade;
        DistanceMeasure    = @(obj1, obj2, data) ...
            spt.amari_index(projmat(obj1)*bprojmat(obj2), 'range', [0 100]);
        SelectionCriterion = ~spt.criterion.dummy;
        DistanceThreshold  = 10;
        ParentSurrogates   = 20;
        ChildrenSurrogates = 40;
        Surrogator         = surrogates.shuffle;
        MaxWindowLength    = @(sr) 60*sr;
        FixNbComponents    = @(nbComponents) ceil(prctile(nbComponents, 75));
        Overlap            = [15 30 50 75];
    end
    
    methods
        function obj = set.Surrogator(obj, value)  
            import exceptions.InvalidPropValue;
            
            if isempty(value),
                obj.Surrogator = surrogates.shuffle;
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
        
        % Redefinitions of abstract_spt methods
        W = projmat(obj, full);
        A = bprojmat(obj, full);
        [y, I] = proj(obj, data, full);
        [y, I] = bproj(obj, data, full);
        
        % Declared and defined here
        function bndry = window_boundary(obj)
            bndry = obj.WinBoundary;
        end

        W     = projmat_win(obj, varargin);
        A     = bprojmat_win(obj, varargin);
    end
    
    methods
        function obj = hierarchical_bss(varargin)
            import misc.set_properties;
            import misc.split_arguments;
            
            error('This algorithm is experimental and does not work yet!');
            
            % Pick the BSS algorithm
            if nargin > 0 && isa(varargin{1}, 'spt.spt'),
                varargin = [{'BSS'}, varargin];
            end
            
            opt.BSS                = spt.bss.jade;
            opt.DistanceMeasure    = @(obj1, obj2, data) ...
                spt.amari_index(projmat(obj1)*bprojmat(obj2), 'range', [0 100]);
            opt.SelectionCriterion = ~spt.criterion.dummy;
            opt.DistanceThreshold  = 10;
            opt.ParentSurrogates   = 20;
            opt.ChildrenSurrogates = 40;
            opt.Surrogator         = surrogates.shuffle;
            opt.MaxWindowLength    = @(sr) 60*sr;
            opt.FixNbComponents    = @(nbComponents) ceil(prctile(nbComponents, 75));
            opt.Overlap            = [15 30 50 75];
            [thisArgs, argsParent] = split_arguments(fieldnames(opt), varargin);
            
            obj = obj@spt.abstract_spt(argsParent{:});
            
            obj = set_properties(obj, opt, thisArgs);
        end
    end
    
end