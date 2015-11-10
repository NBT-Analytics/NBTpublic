`event` package
================

Package `physioset.event` contains classes and functions to define and
manipulate events that may be attached to specific temporal spans of a
[physioset][physioset] object.

[physioset]: ../@physioset/README.md

## The `event` class

Class [physioset.event.event][ev-class] defines the basic data structure
for storing events' information.

### Usage synopsis

Create a 'QRS' event that spans the whole duration of a QRS complex and that
is located around the position of the R-peak:

````matlab
import physioset.event.event;
ev = event(1000, 'Type', 'QRS', 'Offset', -40, 'Duration', 100)
````

which assumes that the QRS complex was located at sample 1000, and that spanned
from sample `1000-Offset = 960` until sample `(1000-Offset)+Duration-1 = 1059`.


## Standard event sub-classes

Package `physioset.event.std` contain various event sub-classes with specific
purposes. These classes are used internally by `meegpipe` and thus you best
avoid using them, unless you really know what you are doing. For instance,
`meegpipe` supports trial-based datasets by adding to the relevant `physioset`
an array of [physioset.event.std.trial_begin][trial_begin] events that mark the
onset and druation of every data trial.

[trial_begin]: ./+std/trial_begin.m


## Event selectors

One of the most common tasks that you are likely to perform on an array of
`event` objects is to select the subset of such events that is relevant for
a given processing task. For instance, the [bad_epochs node][bad_epochs] expects
the user to provide an _event selector_ object which will take care of selecting
the subset of events that define the relevant data epochs.

[bad_epochs]: ../../+meegpipe/+node/+bad_epochs/README.md


### `class_selector`

The `class_selector` event selector is, arguably, the most commonly used one.
Given an array of events, it selects a subset of events of a given `class`, with
a given value of the `Type` property. Consider that we have the following array
of events:

````matlab
import physioset.event.event;
import physioset.event.std.trial_begin;
evArray = [...
    event(1:10, 'Type', 'type1'), ...
    event(50:60, 'Type', 'type2'), ...
    trial_begin(80:90), ...
    trial_begin(91:100, 'Type', 'funnytype') ...
    ];
````

Then:

````matlab
import physioset.event.class_selector;

% Select only the trial_begin events
mySel = class_selector('Class', 'trial_begin');
onlyTrialBeg = select(mySel, evArray);

assert(...
    numel(onlyTrialBeg) == 21 & ...
    all(get_sample(onlyTrialBeg) == 80:100) ...
    );

% Select only events of Type type2
mySel = class_selector('Type', 'type2');
onlyType2 = select(mySel, evArray);

assert(...
    numel(onlyType2) == 11 & ...
    all(get_sample(onlyType2) == 50:60) ...
    );

% Select only trial_begin events of type funnytype
mySel = class_selector('Class', 'trial_begin', 'Type', 'funnytype');
onlyFunnyTrialBeg = select(mySel, evArray);

assert(...
    numel(onlyFunnyTrialBeg) == 10 & ...
    all(get_sample(onlyFunnyTrialBeg) == 91:100) ...
    );
````


### `sample_selector`

The [sample_selector][sample_selector] event selector selects events whose value
of the `Sample` property falls within a given range. For instance the following
code snippet will select all events whose time span falls completely between
samples 50 and 100 or between samples 1000 and 2000:

````matlab
import physioset.event.sample_selector;
import physioset.event.event;

% Create a dummy event array
myEvArray = [...
    event(61:70, 'Type', 'type1'), ...
    event(40, 'Type', 'type2', 'Duration', 20), ... % Not in range!!
    event(1501:1600, 'Type', 'type3') ...
    ];


mySel = sample_selector(50:100, 1000:2000);
newEvArray = select(mySel, myEvArray);

assert(...
    numel(newEvArray) == 110 & ...
    ~ismember('type2', unique(newEvArray)) ...
    );

````


### `value_selector`

The `value_selector` selects events based on the value of their `Value`
property. For instance:

````matlab
import physioset.event.value_selector;
import physioset.event.event;

% Create a dummy event array
myEvArray = [...
    event(61:70, 'Value', 1, 'Type', 'type1'), ...
    event(1501:1600, 'Value', 2, 'Type', 'type2') ...
    ];

% Select only events with Value=2
mySel = value_selector(2);
newEvArray = select(mySel, myEvArray);

assert(...
    numel(newEvArray) == 100 & ...
    ~ismember('type1', unique(newEvArray)) ...
    );
````


## Event generators

You can always create events one by one and embed them into a `physioset` object
using `physioset`'s `add_event()` method. However, sometimes you rather need to
specify a _way of generating events_ rather, e.g. because you still don't know
some of the specifics necessary for generating the actual events. Consider the
case that you want to define an [ev_gen][ev_gen] node that will add peridic
events to the input `physioset` object. You don't know the duration of the
input `physioset` when you are building the [ev_gen][ev_gen] node so you could
not build the train of epoching events and pass that array as an argument to the
constructor of the `ev_gen` node. Instead, you use an `event_generator` object
to specify that the `ev_gen` node should generate as many periodic events as
necessary to span the whole input `physioset`:

````matlab
% Generate a dummy physioset
myData = import(physioset.import.matrix, rand(4,1000));

% We generate non-overlapping events every 60 seconds. Note that you could
% generate overlapping events by setting Period to a value smaller than the
% value of Duration
import physioset.event.periodic_generator;
import meegpipe.node.*;
myEvGen = periodic_generator('Duration', 60, 'Period', 60);
myNode  = ev_gen('EventGenerator', myEvGen);

% Add periodic events to myData
run(myNode, myData);

`````

