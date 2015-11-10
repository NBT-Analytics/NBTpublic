`config` for node `bad_epochs`
======

This class is a helper class that implements consistency checks
necessary for building a valid [bad_epochs][bad_epochs] node. 

[bad_epochs]: ./README.md


## Usage synopsis


````matlab
import meegpipe.node.*;
myNode = bad_epochs.new('key', value, ...)
````


## Configuration properties

The following construction options are accepted by the constructor of 
this config class, and thus by the constructor of the `bad_epochs`
class:


### `EventSelector`

__Class__: `physioset.event.selector`

__Default__: `physioset.event.std.epoch_begin`

The event selector that will select (among all the events in the input 
physioset) those events that are marking the onset and duration of the 
data epochs. 


## `DeleteEvents`

__Class__: `logical scalar`

__Default__: `false`

If `DeleteEvents` is set to true, the events selected with `EventSelector`
will be removed from the input physioset. 


### `Duration`

__Class__: `numeric scalar` or `[]`

__Default__: `[]`

If `Duration` is provided, the duration of the selected events will be 
replaced by `Duration`. `Duration` is specified in seconds.


### `Offset`

__Class__: `numeric scalar` or `[]`

__Default__: `[]`

If `Offset` is provided, the offset of the selected events will be 
replaced by `Offset`. `Offset` is specified in seconds.


### `Criterion`

__Class__ : `meegpipe.node.bad_epochs.criterion.criterion`

__Default__ : `meegpipe.node.bad_epochs.criterion.criterion.stat.stat`
		  
The data epochs rejection criterion. See the documentation of the
[meegpipe.node.bad_epochs.criterion][crit-pkg] for more information on
available rejection criteria.

[crit-pkg]: ./+criterion/README.md
