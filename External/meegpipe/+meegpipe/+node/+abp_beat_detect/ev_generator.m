classdef ev_generator < physioset.event.generator
    
    methods
        
        function evArray = generate(~, data, varargin)
            import physioset.event.std.abp_onset;
            import cardiac_output.wabp;
            
            resData = resample(data(1,:), 125, data.SamplingRate)';
            beatOnsets = wabp(resData);
            
            if isempty(beatOnsets),
                evArray = [];
                return;
            end
            
            % Undo the resampling:
            beatOnsets = round(beatOnsets*(data.SamplingRate/125));
            beatOnsets(beatOnsets < 1) = 1;
            beatOnsets(beatOnsets > size(data,2)) = size(data,2);
            beatOnsets = unique(beatOnsets);    

            % Very simple approach to removing spurious detections
            beatDiff = diff(beatOnsets);
            
            idx = find(beatDiff < 0.3*data.SamplingRate);
            
            if ~isempty(idx),
                beatOnsets(idx+1) = [];
            end         

            evArray = abp_onset(beatOnsets);
        end
        
    end
    
end