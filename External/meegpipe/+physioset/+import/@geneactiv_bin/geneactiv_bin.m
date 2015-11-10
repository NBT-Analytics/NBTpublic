classdef geneactiv_bin < physioset.import.abstract_physioset_import
    % geneactiv_bin - Imports Geneactiv's 3D accelerometry in .bin format
    %
    % Imports [Geneactiv][geneactiv]'s 3D accelerometry in .bin format.
    %
    % [geneactiv]: http://www.geneactive.co.uk/
    %
    % ## Usage synopsis
    %
    % ````matlab
    % import physioset.import.geneactiv_bin;
    %
    % % Get a sample data file (a pair of txt files)
    % urlBase = 'http://kasku.org/data/meegpipe/';
    % urlwrite([urlBase 'pupw_0005_actigraphy_ambulatory.bin.gz'], ...
    %     'sample.bin.gz');
    %
    % % Create a data importer object that will create a physioset object of
    % % single precision
    % importer = dimesimeter('Precision', 'single');
    %
    % % Import the sample file
    % data = import(importer, 'sample.bin.gz');
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
    
    methods (Static, Access = private)
        
        hdr = process_bin_header(hdrIn);
        
    end
    
    % physioset.import.import interface
    methods
        physiosetObj = import(obj, filename, varargin);
    end
    
    
    % Constructor
    methods
        
        function obj = geneactiv_bin(varargin)
            obj = obj@physioset.import.abstract_physioset_import(varargin{:});
        end
        
    end
    
    
end