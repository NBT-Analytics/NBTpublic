classdef pca < spt.abstract_spt
    % PCA - Class for Principal Component Analysis
    
    
    properties (SetAccess = private, GetAccess = private)
        
        Samples;      % # of samples used for training the PCA
        Cov;          % The estimated covariance matrix
        CovRank;      % The column rank of the covariance matrix
        Eigenvectors;
        Eigenvalues;  % Eigenvalues of the estimated cov matrix
        MIBS;
        AIC;
        MDL;
        MIBSOrder;
        AICOrder;
        MDLOrder;        
        
    end
    
    properties
        
        MinSamplesPerParamRatio = 0;
        CovEstimator =   @(x) cov(x);
        RetainedVar  =   99;  % In percentage
        MaxCard      =   Inf;
        MinCard      =   1;
        Criterion    =  'NONE';
        Sphering     =  true; % Should the components be sphered?
        MaxCond      =  Inf;  % Max cond value allowed for the signal subspace
        
    end
    
    % Consistency checks
    methods
        
        function obj = set.MinSamplesPerParamRatio(obj, value)
           import exceptions.InvalidPropValue;
           
           if isempty(value),
               obj.MinSamplesPerDimRatio = 0;
               return;
           end
           
           if numel(value) ~= 1 || ~isnumeric(value) || value < 0,
               throw(InvalidPropValue('MinSamplesPerParamRatio', ...
                   'Must be a positive scalar'));
           end
           obj.MinSamplesPerParamRatio = value;            
            
        end
        
        function obj = set.CovEstimator(obj, value)
            import exceptions.InvalidPropValue;
            
            if isempty(value),
                obj.CovEstimator = @(x) cov(x);
                return;
            end
            
            if ~isa(value, 'function_handle'),
                throw(InvalidPropValue('CovEstimator', ...
                    'Must be a function_handle'));
            end
            
            testEst = value(rand(100, 2));
            
            if ~isnumeric(testEst) || ~all(size(testEst) == [2 2]),
                throw(InvalidPropValue('CovEstimator', ...
                    'The provided covariance estimator is invalid'));
            end
            obj.CovEstimator = value;
            
        end
        
        function obj = set.RetainedVar(obj, value)
            import exceptions.InvalidPropValue;
            
            if isempty(value),
                obj.RetainedVar = 100;
                return;
            end
            
            if isa(value, 'function_handle'),
                testVal = value(rand(1, 100));
                if ~isnumeric(testVal) || numel(testVal) ~= 1 || ...
                        testVal < 0 || testVal > 100,
                    throw(InvalidPropValue('RetainedVar', ...
                        'Invalid function_handle'));
                end
            elseif ~isnumeric(value) || (numel(value) ~= 1 || value < 0 || ...
                    value > 100)
                throw(InvalidPropValue('RetainedVar', ...
                    'Must be a numeric scalar in the range [0, 100]'));
            end
            
            if isnumeric(value) && value < 1 && value > eps,
                warning('pca:Ambiguous', ...
                    'Retaining %.4f%% variance. Did you mean %.2f %%?', ...
                    value, value*100);
            end
            
            obj.RetainedVar = value;
        end
        
        function obj = set.MaxCard(obj, value)
            import exceptions.InvalidPropValue;
            import misc.isnatural;
            
            if isempty(value),
                obj.MaxCard = Inf;
                return;
            end
            
            
            if isa(value, 'function_handle'),
                % Can be a function_handle that takes the eigenvalues as
                % argument
                testVal = value(rand(1,10));
                if numel(testVal) ~= 1 || (~isinf(testVal) && ...
                        ~isnatural(testVal))
                    throw(InvalidPropValue('MaxCard', ...
                        'Invalid function_handle'));
                end
            elseif numel(value) ~= 1 || ...
                    (~isnumeric(value) && ~isa(value, 'function_handle')),
                throw(InvalidPropValue('MaxCard', ...
                    'Must be a natural scalar or a function_handle'));
            end
            
            
            obj.MaxCard = value;
        end
        
        function obj = set.MinCard(obj, value)
            import exceptions.InvalidPropValue;
            
            if isempty(value),
                obj.MinCard = Inf;
                return;
            end
            
            
            if isa(value, 'function_handle'),
                testVal = value(rand(1,10));
                if numel(testVal) ~= 1 || ~isnumeric(testVal)
                    throw(InvalidPropValue('MinCard', ...
                        'Invalid function_handle'));
                end
            elseif numel(value) ~= 1 || ...
                    (~isnumeric(value) && ~isa(value, 'function_handle')),
                throw(InvalidPropValue('MinCard', ...
                    'Must be a natural scalar or a function_handle'));
            end
            
            
            obj.MinCard = value;
        end
        
        function obj = set.Criterion(obj, value)
            import exceptions.InvalidPropValue;
            import misc.isstring;
            import mperl.join;
            
            if isempty(value),
                obj.Criterion = 'NONE';
                return;
            end
            
            validCriteria = keys(spt.pca.valid_criteria);
            if ~isstring(value) || ~ismember(upper(value), validCriteria),
                msg = sprintf('Must be any of these: %s', ...
                    join(',', validCriteria));
                throw(InvalidPropValue('Criterion', msg));
            end
            
            obj.Criterion = upper(value);
        end
        
        function obj = set.Sphering(obj, value)
            import exceptions.InvalidPropValue;
            
            if isempty(value),
                obj.Sphering = true;
                return;
            end
            
            if numel(value) ~=1 || ~islogical(value),
                throw(InvalidPropValue('Sphering', ...
                    'Must be a logical scalar'));
            end
            obj.Sphering = value;
            
        end
        
        function obj = set.MaxCond(obj, value)
            import exceptions.InvalidPropValue;
            
            if isempty(value),
                obj.MaxCond = Inf;
                return;
            end
            
            if numel(value)~=1 || ~isnumeric(value) || value < 1,
                throw(InvalidPropValue('MaxCond', ....
                    'Must be a scalar not less than 1'));
            end
            
            obj.MaxCond = value;
            
        end
        
    end
    
    methods (Static, Access = private)
       y = logpk(eigVal);
    end
    
    methods (Static)
        
        function crit = valid_criteria()
            
            crit = mjava.hash;
            crit('AIC') = 'Akaike''s information criterion';
            crit('MDL') = 'Minimum Description Length criterion';
            crit('MIBS') = 'Minka Bayesian model selection';
            crit('NONE') = 'Do not use any automatic order selection criterion';
        end        
       
        % Component selection methods        
        [kOpt, pk] = mibs(eigValues, n, varargin);        
        [kOpt, pk] = aic(eigValues, n, varargin);        
        [kOpt, pk] = mdl(eigValues, n, varargin); 
        
    end
    
    
    methods
        
        % from spt.abstract_spt
        obj = learn_basis(obj, data)
        
        % redefinition 
        count = fprintf(fid, obj, gallery, makeFig);
        
    end
   
    % constructor
    methods
        
        function obj = pca(varargin)
            import misc.set_properties;
            import misc.split_arguments;
           
            opt.MinSamplesPerParamRatio = 0;
            opt.CovEstimator =   @(x) cov(x);
            opt.RetainedVar  =   99;
            opt.MaxCard      =   Inf;
            opt.MinCard      =   1;
            opt.Criterion    =  'NONE';
            opt.Sphering     =  true;
            opt.MaxCond      =  Inf;
            
            [thisArgs, parentArgs] = ...
                split_arguments(fieldnames(opt), varargin);
            
            obj = obj@spt.abstract_spt(parentArgs{:});            
            
            obj = set_properties(obj, opt, thisArgs{:});
            
            if isempty(get_name(obj)),
                obj = set_name(obj, 'pca');
            end
            
        end
        
    end
    
end