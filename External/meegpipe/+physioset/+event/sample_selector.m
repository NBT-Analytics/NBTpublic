classdef sample_selector < physioset.event.abstract_selector
    
    
    
    properties
        
        Sample  = [];
        Negated = false;
        
    end
    
    methods
        
        function obj = set.Negated(obj, value)
            import exceptions.*;
            
            if numel(value) ~= 1 || ~islogical(value),
                throw(InvalidPropValue('Negated', ...
                    'Must be a logical scalar'));
            end
            obj.Negated = value;
            
        end
        
    end
    
    methods
        
        function obj = not(obj)
            
            obj.Negated = ~obj.Negated;
            
        end
        
        function [evArray, idx] = select(obj, evArray)
            
            if isempty(obj.Sample) || isempty(evArray),
                idx = 1:numel(evArray);
                return;
            end
            
            sample = get_sample(evArray);
            off    = get_offset(evArray);
            dur    = get_duration(evArray);
            
            inRange = false(size(evArray));
            
            for i = 1:numel(evArray)
                
                idx = (sample(i) + off(i)):(sample(i) + off(i) + dur(i) - 1);
                if obj.Negated,
                    inRange(i) = ~all(ismember(idx, obj.Sample));
                else
                    inRange(i) = all(ismember(idx, obj.Sample));
                end
           
            end            
        
            
            evArray = evArray(inRange);           
            
            idx = find(inRange);
            
        end
        
        
    end
    
    
    methods
        
        function obj = sample_selector(varargin)
            
            obj = obj@physioset.event.abstract_selector(varargin{:});
            
            if nargin < 1, return; end
            
            if nargin > 1,
                sampleRange = cell2mat(varargin);
            else
                sampleRange = varargin{1};
            end
            
            obj.Sample = unique(sampleRange);
            
        end
        
        
    end
    
    
end