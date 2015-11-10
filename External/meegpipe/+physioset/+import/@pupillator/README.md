Wisse&Joris pupillator files
================

Imports `.csv` files containing pupil diameter measurements. The format 
of the the `.csv` file follows the convention used by the pupillator 
developed by Wisse van der Meijden and Joris Coppens.

   
## Usage synopsis
  
````matlab
import physioset.import.pupillator;

% Get a sample data file (a pair of txt files)
urlBase = 'http://kasku.org/data/meegpipe/';
urlwrite([urlBase 'pupw_0001_pupillometry_afternoon-sitting_1.csv'], ...
    'sample.csv');

% Create a data importer object
importer = dimesimeter('FileName', 'myOutputFile');

% Import the sample file
data = import(importer, 'sample.csv');
````
 
## Optional construction arguments

The constructor for this data importer accepts all key/values accepted by
[abstract_physioset_import][abs-phys-imp] constructor. There are no 
additional construction arguments specific to this importer class.

[abs-phys-imp]: ../abstract_physioset_import.md


  
