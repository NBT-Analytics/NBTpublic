`config` for node `resample`
=====

This class is a helper class that implements consistency checks
necessary for building a valid [resample][resample] node.

[resample]: ./README.md


## Usage synopsis

Create a node that will select data from certain modalities:

````matlab
% Create a node that will select the subset of EEG data
import meegpipe.node.*;
mySel    = pset.selector.sensor_class('Class', 'EEG');
myConfig = subset.config('SubsetSelector', mySel);
myNode   = subset.new(myConfig);
````

The syntax above is completely equivalent to the (preferred) syntax below:

````matlab
import meegpipe.node.*;
mySel  = pset.selector.sensor_class('Class', 'EEG');
myNode = subset('SubsetSelector', mySel);
````


## Configuration properties

The following construction options are accepted by the constructor of
this `config` class, and thus by the constructor of the `subset`
class:


### `SubsetSelector`

__Class__: `pset.selector.selector`

__Default__: `[]`, i.e. select everything

This property specifies a [selector][selector] object that will be used to 
determine the subset of data that will be used to form the output dataset.

[selector]: http://github.com/germangh/matlab_pset/tree/master/+pset/+selector/README.md
