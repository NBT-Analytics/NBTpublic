`bad_epochs` - bad epochs rejection node
====

The `bad_epochs` node identifies and marks bad epochs in a physioset, based on
a user-provided criterion. Several [pre-defined criteria][predef-crit] are
available and class users can easily define their own custom criteria.

[predef-crit]: ./+criterion/README.md


## Usage synopsis

````matlab
import meegpipe.node.*;
obj = bad_epochs.new('key', value, ...);
data = run(obj, data);
````

where `data` is a [physioset][physioset] object.

[physioset]: ../../../+physioset/@physioset/README.md


## Construction arguments

The `bad_epochs` node admits all the key/value pairs admitted by the
[abstract_node][abstract-node] class. For keys specific to this node
class see the documentation of the helper [config][config] class.

[abstract-node]: ../@abstract_node/README.md
[config]: ./config.md


## Methods

See the documentation of the [node API documentation][node].

[node]: ../


## Default node configurations

### `minmax(minTh, maxTh, 'key', value, ...)`

The `minmax` configuration rejects epochs that exceed a minimum/maximum
threshold. Below an illustration on how to build a `bad_epochs` node that will
reject any epoch whose maximum amplitude exceeds 100 or whose minimum amplitude
is below -50:

````
import meegpipe.node.*;
myNode = bad_epochs.minmax(-50, 100);
````

Note that the `minmax` configuration actually creates a tiny pipeline that
contains two `bad_epochs` nodes. 

### `sliding_window_var(period, dur, 'key', value, ...)`

The `sliding_window_var` configuration can be used to reject bad data 
samples without having to first embed events into the physioset object. 
The `sliding_window_var` configuration produces a small pipeline that 
contains two nodes:

* An [ev_gen node][ev_gen] that generates periodic events with a period of
`period` seconds and a duration of `dur` seconds. 

[ev_gen]: ../+ev_gen/README.md

* A `bad_epochs` node that ranks the epochs generated above according to 
their mean (across channels) variance. 

All additional key/value pairs that are passed to `sliding_window_var` are 
used in the construction of the associated [stat criterion][stat-crit]. That
is, to build a node that will reject those epochs having variance below the 
1% percentile or above the 95% you would do:

````matlab
import meegpipe.node.*;
myNode = bad_epochs.sliding_window_var(0.5, 1, ...
    'Min', @(epochStat) prctile(epochStat, 1), ...
    'Max', @(epochStat) prctile(epochStat, 95));
````

[stat-crit]: ./+criterion/+stat/README.md

By default `period=0.5` and `dur=1`, i.e. the epochs have a duration of 
1 second and there is 50% overlap between correlative epochs.


## Usage examples

All the examples below assume that _meegpipe_ has been initialized using:

````matlab
clear all;
meegpipe.initialize;
````

They also assume that a dummy dataset has been created using:

````matlab
% Create a sample physioset
mySensors  = sensors.eeg.dummy(10);
myImporter = physioset.import.matrix('Sensors', mySensors);
myData = import(myImporter, randn(10, 10000));

% We need to add events marking the onset and durations of the epochs
% As an example, we use non-overlapping epochs of 10s duration
import physioset.event.periodic_generator;
myEventGenerator = periodic_generator('Period', 10, 'Type', 'myType');
myEvents = generate(myEventGenerator, myData);
add_event(myData, myEvents);
````


### Reject epochs with extreme values

The following code snippet rejects all 10-second epochs in a physioset `data`
that exceed (in any channel, in absolute value) a threshold of 100.

````matlab
% Define the epoch rejection criterion
import meegpipe.node.*;
myCrit = bad_epochs.criterion.stat(...
    'ChannelStat',  @(chanValues) max(abs(chanValues)), ...
    'EpochStat',    @(chanStat) max(chanStat));

% Define the event selector
myEvSel = physioset.event.class_selector('Type', 'myType');

% Build the epoch rejection node
myNode = bad_epochs.new('Criterion', myCrit, 'EventSelector', myEvSel);

% Reject epochs that fulfill the rejection criterion
run(myNode, myData);
````
The code above is completely equivalent to the following code, which uses the
`minmax` default configuration:

````matlab
import meegpipe.node.*;

myEvSel = physioset.event.class_selector('Type', 'myType');
myNode = bad_epochs.minmax(-100, 100, 'EventSelector', myEvSel);
run(myNode, myData);
````

### Reject epochs with large variance

The following code can be used to build a node (a pipeline, actually)
that will reject those epochs whose mean variance is 5 median absolute 
deviations above the median mean epoch variance:

````matlab
import meegpipe.node.*;
maxVar = @(epochVars) median(epochVars) + 5*mad(epochVars);
myNode = bad_epochs.sliding_window_var(0.5, 1, maxVar);
run(myNode, myData);
````

Note that in the code above we are using the `sliding_window_var` default
 configuration (see above). 


