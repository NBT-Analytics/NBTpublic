classdef topo_full < spt.feature.feature & goo.verbose
    
   methods
       
       function [featVal, featName] = ...
               extract_feature(~, sptObj, ~, raw, varargin)
          
           featName = labels(sensors(raw));
           
           featVal = bprojmat(sptObj);
           
       end
       
       
   end
    
end