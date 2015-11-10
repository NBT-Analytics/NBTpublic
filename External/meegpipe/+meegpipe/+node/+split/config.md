`config` for node `split`
=====

This class is a helper class that implements consistency checks
necessary for building a valid [split][split] node.

[split]: ./README.md


## Usage synopsis

Create a node that will split the input physioset into single-trial files. 
Each trial onset and duration is determined by events of class 
`trial_begin`, which are embedded in the input physioset:


````matlab
import meegpipe.node.*;
import physioset.event.class_selector;
mySel    = class_selector('Class', 'trial_begin');
myConfig = split.config('EventSelector', mySel);
myNode   = split.new(myConfig);
````

The syntax above is completely equivalent to the (preferred) syntax below:

````matlab
import meegpipe.node.*;
import physioset.event.class_selector;
mySel    = class_selector('Class', 'trial_begin');
myNode   = split.new('EventSelector', mySel);
````


## Configuration properties

The following construction options are accepted by the constructor of
this `config` class, and thus by the constructor of the `split`
class:

### `EventSelector`

__Class__: `physioset.event.selector`

__Default__: `physioset.event.class_selector('Class', 'split_begin')`

This property specifies a [selector][selector] object that will be used to 
determine the subset of data events that will be used to identify the 
onsets and durations of each data split.

[selector]: https://github.com/germangh/matlab_physioset/blob/master/%2Bphysioset/%2Bevent/selector.md


### `Duration`

__Class__: `numeric scalar` or `[]`

__Default__: `[]`

The `Duration` property of the events selected by the `EventSelector` will
 be replaced by this duration. The `Duration` property of the `split` node
__is specified in seconds__, contrary to the `Duration` property of the 
events, which is given in data samples. 


### `Offset`


__Class__: `numeric scalar` or `[]`

__Default__: `[]`

The `Offset` property of the events selected by the `EventSelector` will
 be replaced by this offset. The `Offset` property of the `split` node
__is specified in seconds__, contrary to the `Offset` property of the 
events, which is given in data samples. 


### `SplitNamingPolicy`

__Class__: `function_handle`

__Default__: `@(data, ev, idx) ['split' num2str(idx)]`

This `function_handle` will be used to infer a name for a given data split 
based on the following pieces of information:

* The input physioset object

* The event corresponding to the split

* The index of the split

The names of the generated data files will be obtained as follows:

````
[get_name(data) '_' splitName]
````

So, if the input physioset has name `0001_eeg_rs` and there are two 
split-generated events the default names of the generated files will be:

````
0001_eeg_rs_split1.pseth
0001_eeg_rs_split1.pset
0001_eeg_rs_split2.pseth
0001_eeg_rs_split2.pset
````
 

