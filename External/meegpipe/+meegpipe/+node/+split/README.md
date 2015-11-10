`split` - Split physioset using events
====

`split` nodes create various physiosets as subsets of the input physioset. 
The subsets are identified using events in the input dataset. 


## Usage synopsis

Split the input physioset based on the presence of events of class 
`trial_begin`:

````matlab
import meegpipe.node.*;
import physioset.event.class_selector;
import physioset.event.std.trial_begin;

% Create a sample physioset
data = import(physioset.import.matrix, randn(10, 1000));
evArray = trial_begin(1:100:900, 'Duration', 100);
add_event(data, evArray);

% Create a suitable event selector
mySel      = class_selector('Class', 'trial_begin');
myNode     = split.new('EventSelector', mySel);
dataSplits = run(myNode, data);

% Check that everything worked
assert(numel(dataSplits) == 9 & size(dataSplits{1},2) == 100);
````


## Construction arguments

The `split` node admits all the key/value pairs admitted by the
[abstract_node][abstract-node] class. For keys specific to this node
class see the documentation of the helper [config][config] class.

[abstract-node]: ../@abstract_node/README.md
[config]: ./config.md


## Methods

See the documentation of the [node API documentation][node].

[node]: ../


## Usage examples

The example below assume that _meegpipe_ has been initialized using:

````matlab
clear all;
meegpipe.initialize;
````


### Use a custom naming policy

The default naming of the data files associated to the generated data 
splits is as follows:

````
[get_name(inputData) '_split' num2str(splitIdx)] 
````

where `inputData` is the `physioset` object at the input of the node, and 
`splitIdx` is the index of a given split. You can modify the custom naming 
policy using the [configuration property][config] `SplitNamingPolicy`. For 
instance consider the case that our input physioset contains three 
`trial_begin` events that identify the onsets and duration of three 
different experimental conditions (e.g. conditions `rest`, `pvt`, `rsq`). 
Consider also that the duration of each of these conditions is 5 minutes. 
The following code snippet will split the input physioset into three 
physiosets, each containing individual conditions' data, and named so that
the condition name appears as a suffix of the associated disk file:

````matlab
import meegpipe.node.*;
import physioset.event.class_selector;
import physioset.event.std.trial_begin;

% Create a dummy physioset that emulates our use-case

% We assume a sampling rate of 10 Hz
myImporter = physioset.import.matrix('SamplingRate', 10);
data = import(myImporter, randn(5, 10000));

% We assume that the conditions onsets and names are encoded in the data
% events. 
ev1 = trial_begin(1000, 'Type', 'rest');
ev2 = trial_begin(4000, 'Type', 'pvt');
ev3 = trial_begin(7000, 'Type', 'rsq');
add_event(data, [ev1;ev2;ev3]);

% In this case our dataset only contains trial_begin events, but in general
% we should create a suitable event selector
mySel      = class_selector('Class', 'trial_begin');

% The naming policy is specified using a function_handle that takes three 
% arguments: (1) the physioset at the input of the node, (2) the event 
% generating the split, (3) the index of the split. Whatever the 
% function_handle evaluates to will be concatenated to the name of the 
% input physioset.
namingPolicy = @(data, ev, idx) get(ev, 'Type');

% We are now ready to build our split node
myNode = split.new(...
    'EventSelector',        mySel, ...
    'SplitNamingPolicy',    namingPolicy, ...
    'Duration',             5*60 ... % Split duration in seconds!
);

dataSplits = run(myNode, data);

````
