classdef physioset_export
    % physioset_export - Interface for physioset data exporters
    %
    %
    %
    % See also: physioset
    
   methods (Abstract)
       varargout = export(obj, filename, varargin); 
   end
    
    
end