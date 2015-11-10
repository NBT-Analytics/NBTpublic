dimesimeter light measurements importer
================

Imports [Dimesimeter][dimesimeter]'s ambient light measurements in `.txt`
format

[dimesimeter]: http://www.lrc.rpi.edu/programs/lighthealth/projects/Dimesimeter.asp
    
## Usage synopsis
  
````matlab
import physioset.import.dimesimeter;

% Get a sample data file (a pair of txt files)
urlBase = 'http://kasku.org/data/meegpipe/';
urlwrite([urlBase 'pupw_0001_ambient-light_coat_ambulatory_header.txt'], ...
    'sample_header.txt');
urlwrite([urlBase 'pupw_0001_ambient-light_coat_ambulatory.txt'], ...
    'sample.txt');

% Create a data importer object
importer = dimesimeter('FileName', 'myOutputFile');

% Import the sample file
data = import(importer, 'sample_header.txt');
````
 
## Optional construction arguments

The constructor for this data importer accepts all key/values accepted by
[abstract_physioset_import][abs-phys-imp] constructor. There are no 
additional construction arguments specific to this importer class.

[abs-phys-imp]: ../abstract_physioset_import.md


  
