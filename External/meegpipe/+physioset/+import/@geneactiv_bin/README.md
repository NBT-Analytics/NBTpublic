geneactiv_bin data importer
================

Imports [Geneactiv][geneactiv]'s 3D accelerometry in .bin format.

[geneactiv]: http://www.geneactive.co.uk/
    
## Usage synopsis
  
````matlab
import physioset.import.geneactiv_bin;

% Get a sample data file (a pair of txt files)
urlBase = 'http://kasku.org/data/meegpipe/';
urlwrite([urlBase 'pupw_0005_actigraphy_ambulatory.bin.gz'], ...
    'sample.bin.gz');

% Create a data importer object that will create a physioset object of 
% single precision
importer = geneactiv_bin('Precision', 'single');

% Import the sample file
data = import(importer, 'sample.bin.gz');
````
 
## Optional construction arguments

The constructor for this data importer accepts all key/values accepted by
[abstract_physioset_import][abs-phys-imp] constructor. There are no 
additional construction arguments specific to this importer class.

[abs-phys-imp]: ../abstract_physioset_import.md