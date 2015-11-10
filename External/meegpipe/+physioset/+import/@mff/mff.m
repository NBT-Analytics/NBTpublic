classdef mff < physioset.import.abstract_physioset_import
    % MFF - Imports Netstation MFF files
    %
    % ## Usage synopsis:
    %
    % import physioset.import.mff;
    % importer = mff('FileName', 'myOutputFile');
    % data = import(importer, 'myFile.mff');
    %
    % ## Accepted (optional) construction arguments (as key/values):
    %
    % * All key/values accepted by abstract_physioset_import constructor
    %
    % See also: abstract_physioset_import
 
   
    properties
       ReadDataValues = true; 
    end
    
    % physioset.import.import interface
    methods
        physiosetObj = import(obj, filename, varargin);        
    end
    
    
    % Constructor
    methods
        
        function obj = mff(varargin)
            obj = obj@physioset.import.abstract_physioset_import(varargin{:});             
        end
        
    end
    
    
end