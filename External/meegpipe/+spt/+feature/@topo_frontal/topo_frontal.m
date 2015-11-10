classdef topo_frontal < spt.feature.feature & goo.verbose
    
    properties
       % 
       R0 = 0.65; 
       R1 = 1;
       % Spatial filter operator to be applied before computing the power
       % ratio between frontal and non-frontal channels
       SpatialFilter = @(x) median(x);
       % The order (number of neighboring channels) to be passed to the
       % filter operator
       SpatialFilterOrder = 5; 
       % Do not perform spatial filtering if the number of channels does
       % not exceed this threshold
       SpatialFilterMinChannels = 40;
    end
    
    methods
        
        [idx, featName] = extract_feature(obj, sptObj, tSeries, raw, varargin);

        % Constructor
        function obj = topo_frontal(varargin)
            import misc.set_properties;
            
            if nargin < 1, return; end
            
            opt.R0 = 0.65;
            opt.R1 = 1;  
            opt.SpatialFilter = @(x) median(x);
            opt.SpatialFilterOrder = 5;
            opt.SpatialFilterMinChannels = 40;
           
            obj = set_properties(obj, opt, varargin);
            
        end
    end
    
    
end