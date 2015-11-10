classdef physioset_import
    % PHYSIOSET_IMPORT - Interface for physioset data importers
    %
    %
    %
    % See also: physioset.import.abstract_physioset_import, pset.import
    
   methods (Abstract)
       varargout = import(obj, filename, varargin); 
   end
    
    
end