classdef dimesimeter < physioset.import.abstract_physioset_import
    % dimesimeter - Imports Geneactiv's 3D accelerometry in .bin format
    %
    % Imports [Dimesimeter][dimesimeter]'s ambient light measurements in
    % `.txt` format
    %
    % [dimesimeter]: http://www.lrc.rpi.edu/programs/lighthealth/projects/Dimesimeter.asp
    %
    % ## Usage synopsis
    %
    % ````matlab
    % import physioset.import.dimesimeter;
    %
    % % Get a sample data file (a pair of txt files)
    % urlBase = 'http://kasku.org/data/meegpipe/';
    % urlwrite([urlBase 'pupw_0001_ambient-light_coat_ambulatory_header.txt'], ...
    %     'sample_header.txt');
    % urlwrite([urlBase 'pupw_0001_ambient-light_coat_ambulatory.txt'], ...
    %     'sample.txt');
    %
    % % Create a data importer object
    % importer = dimesimeter('FileName', 'myOutputFile');
    %
    % % Import the sample file
    % data = import(importer, 'sample_header.txt');
    % ````
    %
    % ## Optional construction arguments
    %
    % The constructor for this data importer accepts all key/values accepted by
    % [abstract_physioset_import][abs-phys-imp] constructor. There are no
    % additional construction arguments specific to this importer class.
    %
    % [abs-phys-imp]: ../abstract_physioset_import.md
    %
    %
    % See also: abstract_physioset_import
 
    
    % physioset.import.import interface
    methods
        physiosetObj = import(obj, filename, varargin);        
    end
    
    
    % Constructor
    methods
        
        function obj = dimesimeter(varargin)
            obj = obj@physioset.import.abstract_physioset_import(varargin{:});             
        end
        
    end
    
    
end