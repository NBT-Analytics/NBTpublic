`config` for node `ev_features`
===

This class is a helper class that implements consistency checks necessary for
building a valid [ev_features][ev_features] node.

[ev_features]: ./README.md

## Usage synopsis

Extract event time (`Time`) and response time (`rsp`) features from all
TRSP events in a physioset:

````matlab
import meegpipe.node.*;
mySel    = physioset.event.class_selector('Type', 'TRSP');
myConfig = ev_features.config(...
    'EventSelector', mySel, ...
    'Features',     {'Time', 'TRSP'});

myNode = ev_features.new(myConfig);
````
Altenatively, the following syntax is equivalent, and preferable for being
more concise:

````matlab
import meegpipe.node.*;
mySel    = physioset.event.class_selector('Type', 'TRSP');
myNode   = ev_features.new(...
    'EventSelector', mySel, ...
    'Features',     {'Time', 'TRSP'});
````

## Configuration properties


The following construction options are accepted by the constructor of
this config class, and thus by the constructor of the `erp` node class:


### `EventSelector`

__Class__: `physioset.event.selector`

__Default__: physioset.event.class_selector('Type', 'erp')

The provided `selector` will be used to select the ERP-relevant events from the
events present in the input `physioset`.


### `Features`

__Class__: `cell array`

__Default__: ` { 'Type' , 'Sample' , 'Time' , 'Duration'}`

The `Features` property specifies what event properties should be extracted
from the events. The default setting will create a features table with four 
columns corresponding to the `Type`, `Sample`, `Time` and `Duration` of all
selected events.

### `Feature2String`

__Class__: `mjava.hash`

__Default__: `mjava.hash('Time', @(x) datestr(x));`

This property can be used to provide custom value to string mappers for 
different features. By default, all feature values are converted to strings
using `misc.any2str`. The default setting of `Feature2String` ensures that 
the `Time` property of the events is converted into a string using MATLAB's
`date2str`.
