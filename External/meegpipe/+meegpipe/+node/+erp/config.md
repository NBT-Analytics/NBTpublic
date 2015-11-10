`config` for node `erp`
===

This class is a helper class that implements consistency checks necessary for
building a valid [erp][erp] node.

[erp]: ./README.md

## Usage synopsis

Create an ERP waveform based on events of type `mytype`, by aggregating the ERPs
in channels with labels `EEG 5` and `EEG 7`:

````matlab
import meegpipe.node.*;
mySel    = physioset.event.class_selector('Type', 'mytype');
myConfig = erp.config(...
    'EventSelector', mySel, ...
    'Duration',      0.7, ...       % In seconds
    'Offset',       -0.1, ...       % In seconds
    'Baseline',     [-0.1 0]);      % Leave empty if don't want baseline corr.

myNode = erp.new(myConfig);
````
Altenatively, the following syntax is equivalent, and preferable for being
more concise:

````matlab
import meegpipe.node.*;
mySel    = physioset.event.class_selector('Type', 'mytype');
myNote   = erp.new(...
    'EventSelector', mySel, ...
    'Duration',      0.7, ...       % In seconds
    'Offset',       -0.1, ...       % In seconds
    'Baseline',     [-0.1 0]);      % Leave empty if don't want baseline corr.
````

## Configuration properties


The following construction options are accepted by the constructor of
this config class, and thus by the constructor of the `erp` node class:

### `AvgWindow`

__Class__: `numeric scalar`

__Default__: `0.05`

Size of the window (in seconds) around the peak that will be used to calculate
the average peak amplitude.

### `Baseline`

__Class__: `1x2 numeric vector`

__Default__: `[]`

The temporal range (relative to event onset, in seconds) that is to be used for
baseline correction. Leave empty if no baseline correction should be performed.

### `Channels`

__Class__: `cell array` or a `string` (a regular expression)

__Default__: '.+'

A regular expression (or a list of regular expressions) to be matched against
the labels of the data channels. An ERP image will be generated for each regular
expression, and the corresponding ERP features will be exported to a text file.


### `Duration`

__Class__: `numeric scalar`

__Default__: `[]`

The duration of the ERP waveform in seconds. If not provided, the duration of
the selected events will be used.


### `EventSelector`

__Class__: `physioset.event.selector`

__Default__: `physioset.event.class_selector('Type', 'erp')`

The provided `selector` will be used to select the ERP-relevant events from the
events present in the input `physioset`.

### `Filter`

__Class__: `filter.dfilt`

__Default__: `[]`

A filter to be applied to the average ERP waveforms. E.g. to apply a moving
average filter of order 3 you could define the `Filter` property to be
`filter.ab(1, ones(1,3)/3)`.


### `Offset`

__Class__: `numeric scalar`

__Default__: `[]`

The offset of the ERP waveform in seconds, relative to the event onset. If not
provided, the `Offset` property of the selected events will be used.

### `MinMax`

__Class__: `string`

__Default__: `'max'`

If set to `'min'` the ERP peak is to be found at a local minimum. If set to
`'max'`, then it is to be found at a local maximum.


### `PeakLatRange`

__Class__: `1x2 numeric vector`

__Default__: `[0.1 Inf]`

If specified (i.e. if not empty), the ERP peak will be searched only within this
temporal window (in seconds, relative to stimulus onset). This parameter is of
great importance for accurately determining the ERP features extracted by this
node.
