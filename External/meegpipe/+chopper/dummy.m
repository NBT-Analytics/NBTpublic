classdef dummy < chopper.abstract_chopper
    % DUMMY -  A dummy chooper that does not do any chopping
    %
    %
    %
    % See also: chopper.ged, chopper
    
    
    % chopper.chopper interface
    methods
        function [bndry, index] = chop(~, data, varargin)
            
            bndry = false(1, size(data,2));
            bndry([1 size(data,2)]) = true;
            index = zeros(1, size(data,2));
            
            
        end
    end
    
    
end