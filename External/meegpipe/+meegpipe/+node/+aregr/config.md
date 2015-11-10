`config` for node `aregr`
===


This class is a helper class that implements consistency checks
necessary for building a valid [aregr][aregr] node.

[aregr]: ./README.md

## Usage synopsis:


````matlab
import meegpipe.node.*;
myRegrFilter = filter.mlag_regr('Order', 5);
myMeasSel    = pset.selector.sensor_idx(1:5);
myRegrSel    = pset.selector.sensor_idx(6:7);
myNode       = aregr.new('Filter',      myRegrFilter, ...
                         'Measurement', myMeasSel, ...
                         'Regressor',   myRegrSel);
````

## Configuration properties

The following construction options are accepted by the constructor of
this config class, and thus by the constructor of the `aregr`
class:

### `ChopSelector`

__Class__: `pset.selector.selector` or `[]`

__Default__: `[]`

This selector will be used to identify chop events from the events present in
the input physioset. If chop events are found, the regression will be performed
in each data chop separately.


### `ExpandBoundary`

__Class__: `logical`

__Default__: `false`

If set to true, the effective chop duration will be expanded 2% in both
directions to minimize discontinuities between data chops.


### `Filter`

__Class__ : `filter.rfilt` or `function_handle`

__Default__: `filter.mlag_regr`

The (possibly adaptive) filtering algorithm. If set to a `funtion_handle`, the
actual filter will be obtained by evaluating the `Filter` at the sampling rate
of the input data.


### `Measurement`

__Class__ : `pset.selector.selector` or `[]`

__Default__ : `[]`

The selector that will be used to identify select the regression targets (i.e.
the measurements) out of the input physioset object. See the documentation of
the [selector package][sel-pkg] for more information on available selectors and
how to define your own data selectors.

### `Regressor`

__Class__ : `pset.selector.selector` or `[]`

__Default__ : `[]`

The selector that will be used to identify select the regressors out of the
input physioset object. See the documentation of the [selector package][sel-pkg]
for more information on available selectors and how to define your own data
selectors.

[sel-pkg]: https://github.com/germangh/matlab_pset/tree/master/%2Bpset/%2Bselector

