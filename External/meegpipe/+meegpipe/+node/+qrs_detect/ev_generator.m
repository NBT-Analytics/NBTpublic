classdef ev_generator < physioset.event.generator
    
    methods
        
        function evArray = generate(~, data, varargin)
            import physioset.event.std.qrs;
            import fmrib.my_fmrib_qrsdetect;
            
            rpeaks = my_fmrib_qrsdetect(data(:,:), data.SamplingRate, false);
            
            evArray = qrs(rpeaks);
        end
        
    end
    
end