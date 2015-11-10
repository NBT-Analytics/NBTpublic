classdef sample_epochs < spt.feature.feature & goo.verbose
    % SAMPLE_EPOCHS - Computes lower-level feature in a few sample epochs
    
    properties
        Feature  = [];
        NbEpochs = 10;
        EpochDur = 10000;   % In samples
        AggregatingStat = @(x) median(x);
    end
    
    
    
    methods
        
        % Consistency
        function obj = set.Feature(obj, value)
            import exceptions.InvalidPropValue;
            
            if isempty(value),
                obj.Feature = [];
                return;
            end
            
            if numel(value) ~= 1 || ~isa(value, 'spt.feature.feature'),
                throw(InvalidPropValue('Feature', ...
                    'Must be a spt.feature.feature object'));
            end
            obj.Feature = value;
            
        end
        
        function [aggrFeatVal, featName] = extract_feature(obj, sptObj, ...
                tSeries, varargin)
            import exceptions.Inconsistent;
            
            featName = [];
            
            if isempty(obj.Feature),
                throw(Inconsistent('Property Feature must be specified'));
            end
            
            epochDur = obj.EpochDur;
            if isa(epochDur, 'function_handle'),
                epochDur = epochDur(varargin{1}.SamplingRate);
            end
            
            if epochDur > size(tSeries, 2),
                warning('sample_epochs:NotEnoughData', ...
                    ['Cannot use epochs of %d samples (only %d samples ' ...
                    'available): using %d samples instead'], ...
                    epochDur, size(tSeries, 2), size(tSeries, 2));
                epochDur = size(tSeries, 2);
            end
            
            epochOnsets = 1:epochDur:(size(tSeries,2)-epochDur);
            
            if numel(epochOnsets) > obj.NbEpochs,
                idx = round(linspace(1, numel(epochOnsets), obj.NbEpochs));
                epochOnsets = epochOnsets(idx);
            elseif isempty(epochOnsets),
                epochOnsets = 1;
                epochDur    = size(tSeries, 2);
            end
            
            featVal = nan(size(tSeries,1), numel(epochOnsets));
            for i = 1:numel(epochOnsets)
                samplesIdx = epochOnsets(i):epochOnsets(i)+epochDur-1;
                if isa(tSeries, 'pset.mmappset'),
                    select(tSeries, [], samplesIdx);
                    thisTS = tSeries;
                else
                    thisTS = tSeries(:, samplesIdx);
                end
                featVal(:, i) = extract_feature(obj.Feature, sptObj, thisTS, varargin{:});
                if isa(tSeries, 'pset.mmappset'),
                    restore_selection(tSeries);
                end
            end
            
            if size(featVal, 2) < 2,
                aggrFeatVal = featVal;
                return;
            end
            
            aggrFeatVal = nan(size(featVal, 1), 1);
            for i = 1:size(tSeries, 1),
                aggrFeatVal(i) = obj.AggregatingStat(featVal(i,:));
            end
            
        end
        
        % Constructor
        function obj = sample_epochs(varargin)
            import misc.set_properties;
            
            if nargin < 1, return; end
            
            
            opt.Feature  = [];
            opt.NbEpochs = 10;
            opt.EpochDur = 10000;    % In samples, or a function_handle of sr
            opt.AggregatingStat = @(x) median(x);
            
            if isa(varargin{1}, 'spt.feature.feature'),
                opt.Feature = varargin{1};
                varargin = varargin(2:end);
            end
            
            obj = set_properties(obj, opt, varargin);
            
        end
        
    end
    
    
end