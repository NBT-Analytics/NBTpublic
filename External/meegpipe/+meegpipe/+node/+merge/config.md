`config` for node `merge`
=====

This class is a helper class that implements consistency checks
necessary for building a valid [merge][merge] node.

[merge]: ./README.md


## Usage synopsis

Create a node that will merge files `file1.mff1` and `file2.mff` into a 
single physioset object:


````matlab
import meegpipe.node.*;
myConfig = merge.config('Importer', physioset.import.mff);
myNode   = merge.new(myConfig);
````

The syntax above is completely equivalent to the (preferred) syntax below:

````matlab
import meegpipe.node.*;
myNode   = merge.new('Importer', physioset.import.mff);
````


## Configuration properties

The following construction options are accepted by the constructor of
this `config` class, and thus by the constructor of the `merge`
class:

### `Importer`

__Class__: `physioset.import.physioset_import`

__Default__: `{}`

The [data importer][import-pkg] object that will be used to import the data
files. Multiple importers can be provided as a cell array of importer 
objects. 

[import-pkg]: https://github.com/germangh/matlab_physioset/blob/master/+physioset/+import/README.md

