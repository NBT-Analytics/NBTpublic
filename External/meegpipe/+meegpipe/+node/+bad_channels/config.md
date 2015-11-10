`config` for node `bad_channels`
======

This class is a helper class that implements consistency checks
necessary for building a valid [bad_channels][bad_channels] node. 

[bad_channels]: ./README.md

## Usage synopsis

Create a `bad_channels` node that will reject all channels whose
variance is not within 20 median absolute deviations of the median
channel variance:


````matlab
import meegpipe.node.bad_channels.*;
myCriterion = criterion.var.config('MADs', 20);
myNode      = bad_channels('Criterion', myCriterion);
````

## Configuration properties

The following construction options are accepted by the constructor of 
this config class, and thus by the constructor of the `bad_channels`
class:

### `Criterion`

__Class__ : `meegpipe.node.bad_channels.criterion.criterion`

__Default__ : `meegpipe.node.bad_channels.criterion.criterion.var.var`
		  
The data channel rejection criterion. See the documentation of the
[meegpipe.node.bad_channels.criterion][crit-pkg] for more information on
available criteria and instruction on how to define your own selection
criteria.

[crit-pkg]: ./+criterion/README.md
