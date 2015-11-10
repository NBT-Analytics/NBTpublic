classdef qrs_erp < spt.feature.feature & goo.verbose
    % QRS_ERP - Stabibility of QRS-locked ERP
    
    properties
        
        % For building the ERP
        Duration            = 0.4;  % in seconds
        Offset              = 0.08; % in seconds
        NbEpochs            = 10;   % Number of epochs for QRS ERP compuation
        EpochDuration       = 40;   % In seconds
        Filter              = [];   % A pre-processind digital filter
        CorrAggregationStat = @(x) prctile(x, 75);
        EpochAggregationStat = @(x) median(x);
        
    end
    
    methods
        
        % Consistency checks
        function obj = set.Filter(obj, value)
            import exceptions.InvalidPropValue;
            
            if isempty(value),
                obj.Filter = [];
                return;
            end
            
            if numel(value) ~= 1 || (~isa(value, 'filter.dfilt') && ...
                    ~isa(value, 'function_handle')),
                throw(InvalidPropValue('Filter', ...
                    'Must be a filter.dfilt or a function_handle'));
            end
            
            if isa(value, 'function_handle'),
                testVal = value(500);
                if ~isa(testVal, 'filter.dfilt'),
                    throw(InvalidPropValue('Filter', ...
                        'Must evaluate to a filter.dfilt object'));
                end
            end
            
            obj.Filter = value;
        end
        
        % spt.feature.feature interface
        [featVal, featName] = extract_feature(obj, ~, tSeries, varargin);
        
        % Constructor
        function obj = qrs_erp(varargin)
            import misc.set_properties;
            
            if nargin < 1, return; end
            
            % For building the ERP
            opt.Duration      = 0.4;  % in seconds
            opt.Offset        = 0.08; % in seconds
            opt.Filter        = [];
            opt.EpochDuration = 40;
            opt.NbEpochs      = 10;
            opt.CorrAggregationStat = @(x) prctile(x, 75);
            obj = set_properties(obj, opt, varargin);
        end
        
    end
    
    
    
end