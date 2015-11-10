`config` for node `generic_features`
===

This class is a helper class that implements consistency checks necessary for
building a valid [generic_features][generic_features] node.

[generic_features]: ./README.md

## Usage synopsis

For all channels extract the following sets of features:

* The average signal amplitude in blocks 4, 5, 7, normalized by the average
signal amplitude in blocks 2 and 3.

* The average signal amplitude across all blocks.

We will assume that block onsets and durations are marked by events of 
type `block`, and that the block number is stored in the `Value` property
of the correspoding block event.


````matlab
import meegpipe.*;
import physioset.event.value_selector;

mySel1 = pset.selector.event_selector(value_selector(4,5,7));
mySel2 = pset.selector.event_selector(value_selector(2,3));
mySel3 = pset.selector.event_selector(value_selector(8));

myFirstLevelFeature  = {@(x, ev, dataSel) mean(x)};
mySecondLevelFeature = {@(x, ev, dataSel) x(1)/x(2), ...
    @(x, selectorArray) mean(x)};

myConfig = node.generic_features.config(...
    'TargetSelector', {mySel1, mySel2, mySel3}, ...
    'FirstLevel',     myFirstLevelFeature, ...
    'SecondLevel',    mySecondLevelFeature, ...
    'FeatureNames',   {'funnyratio'});

myNode = generic_features.new(myConfig);
````

The following syntax is equivalent:


````matlab
import meegpipe.*;
import physioset.event.value_selector;

mySel1 = pset.selector.event_selector(value_selector(4,5,7));
mySel2 = pset.selector.event_selector(value_selector(2,3));
mySel3 = pset.selector.event_selector(value_selector(8));

myFirstLevelFeature  = {@(x, ev, dataSel) mean(x)};
mySecondLevelFeature = {@(x, ev, dataSel) x(1)/x(2), ...
    @(x, evArray) (get_duration(evArray)./sum(get_duration(evArray))).*x};

myConfig = node.generic_features.config(...
    'TargetSelector', {mySel1, mySel2, mySel3}, ...
    'FirstLevel',    myFirstLevelFeature, ...
    'SecondLevel',   mySecondLevelFeature, ...
    'FeatureNames',   {'funnyratio'});

myNode = node.generic_features.new(myConfig);
````


## Configuration properties


The following construction options are accepted by the constructor of
this config class, and thus by the constructor of the `erp` node class:


### `TargetSelector`

__Class__: `pset.selector.selector`

__Default__: `[]`, i.e. select all data

A cell array of selector objects that will be used to select targets for 
feature extraction. For instance:

````matlab
import meegpipe.node.*;
import physioset.event.value_selector;
import physioset.event.class_selector;
import physioset.event.cascade_selector;
import pset.selector.event_selector;

myEvSel1 = class_selector('Type', 'block');
myEvSel2 = value_selector(4,5,7);
myEvSel1 = cascade_selector(myEvSel1, myEvSel2);
mySel1   = event_selector(myEvSel1);

myEvSel2 = value_selector(2,3);
myEvSel2 = cascade_selector(myEvSel1, myEvSel2);
mySel2 = pset.selector.event_selector(myEvSel2); 

myNode = generic_features.new(...
    'TargetSelector', {mySel1, mySel2});
````

will extract features from:

* The subset of data delimited by `block` events with `Value` equal to 
4, 5, 7.

* The subset of data delimited by `block` events with `Value` equal to 
2, 3.



### `FirstLevel`

__Class__: `cell array` of `function_handle`

__Default__: `{@(x) mean(x)}`


Property `FirstLevel` specifies the feature extraction function for each 
target selection.

For instance:

````matlab
import meegpipe.node.*;
import physioset.event.value_selector;
import physioset.event.class_selector;
import physioset.event.cascade_selector;
import pset.selector.event_selector;

myEvSel1 = class_selector('Type', 'block');
myEvSel2 = value_selector(4,5,7);
myEvSel1 = cascade_selector(myEvSel1, myEvSel2);
mySel1   = event_selector(myEvSel1);

myEvSel2 = value_selector(2,3);
myEvSel2 = cascade_selector(myEvSel1, myEvSel2);
mySel2 = pset.selector.event_selector(myEvSel2); 

myNode = generic_features.new(...
    'TargetSelector',   {mySel1, mySel2}, ...
    'FirstLevel',       @(x, ev, dataSel) mean(x(:)), ...
    'FeatureNames',     {'mean'});
````

will extract two features from a physioset:

* The mean signal value (across channels) for blocks 4, 5, 7.

* The mean signal value (across channels) for blocks 2, 3.

Note that each `function_handle` in `FirstLevel` must produce 
__a numeric scalar value__. 

See below for explanations on the purpose of the mandatory argument 
`FeatureNames`. 


### `SecondLevel` 

__Class__: `cell array` of `function_handle` or `[]`

__Default__: `[]`

Property `SecondLevel` can be used to aggregate first level features. For
instance:

````matlab
import meegpipe.node.*;
import physioset.event.value_selector;
import physioset.event.class_selector;
import physioset.event.cascade_selector;
import pset.selector.event_selector;

myEvSel1 = class_selector('Type', 'block');
myEvSel2 = value_selector(4,5,7);
myEvSel1 = cascade_selector(myEvSel1, myEvSel2);
mySel1   = event_selector(myEvSel1);

myEvSel2 = value_selector(2,3);
myEvSel2 = cascade_selector(myEvSel1, myEvSel2);
mySel2 = pset.selector.event_selector(myEvSel2); 

myNode = generic_features.new(...
    'TargetSelector',   {mySel1, mySel2}, ...
    'FirstLevel',       @(x, ev, dataSel) mean(x(:)), ...
    'SecondLevel',      @(x, ev, dataSel) x(2)/x(1), ...
    'FeatureNames',     {'ratioOfAverages'});
````

will compute just one feature: the result of dividing the average signal 
value (across channels) for blocks 4, 5, 7 by the average signal value 
(across channels) for blocks 2, 3.


Note that each `function_handle` in `SecondLevel` must produce a 
__numeric scalar value__.

See below for explanations on the purpose of the mandatory argument 
`FeatureNames`. 


### `FeatureNames`

__Class__: `cell array of strings`

__Default__: `{'mean'}`


A cell array with the names of the extracted features. The dimensions of 
`FeatureNames` must match the dimensions of the `FirstLevel` and 
`SecondLevel` properties. Namely:

````
size(FeatureNames) == [numel(FirstLevel) numel(SecondLevel)]
````

For instance:

````matlab
import meegpipe.node.*;
import physioset.event.value_selector;
import physioset.event.class_selector;
import physioset.event.cascade_selector;
import pset.selector.event_selector;

myEvSel1 = class_selector('Type', 'block');
myEvSel2 = value_selector(4,5,7);
myEvSel1 = cascade_selector(myEvSel1, myEvSel2);
mySel1   = event_selector(myEvSel1);

myEvSel2 = value_selector(2,3);
myEvSel2 = cascade_selector(myEvSel1, myEvSel2);
mySel2 = pset.selector.event_selector(myEvSel2); 

myNode = generic_features.new(...
    'TargetSelector',   {mySel1, mySel2}, ...
    'FirstLevel',       {@(x, ev, dataSel) mean(x(:)), @(x) median(x(:))}, ...
    'SecondLevel',      {@(x, ev, dataSel) x(2)/x(1), @(x)x(2)*x(1)}, ...
    'FeatureNames',     ...
        {'ratioOfMeans', 'prodOfMeans';'ratioOfMedians', 'prodOfMedians'});
````


### `AuxVars`

__Class__: `cell array` of `function_handle` or `{}`

__Default__: `{}`

A list of auxiliary variables that should be pre-computed and passed along 
to all feature extractors.


