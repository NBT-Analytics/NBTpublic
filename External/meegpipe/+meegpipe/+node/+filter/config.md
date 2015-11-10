`config` for node `filter`
===

This class is a helper class that implements consistency checks necessary
for building a valid [filter][filter] node.

[erp]: ./README.md

## Usage synopsis

Filter data using a bandpass filter with passband between 2 and 30 Hz:

````matlab
import meegpipe.node.*;

% The low-level filter object
myFilter = @(sr) filter.bpfilt('fp', [2 30]/(sr/2))
myConfig = filter.config('Filter', myFilter);

myNode = filter.new(myConfig);
````
Altenatively, the following syntax is equivalent, and preferable for being
more concise:

````matlab
import meegpipe.node.*;

% The low-level filter object
myFilter = @(sr) filter.bpfilt('fp', [2 30]/(sr/2))
myNode = filter.new('Filter', myFilter);
````

## Configuration properties


The following construction options are accepted by the constructor of
this config class, and thus by the constructor of the `filter` node class:

### `Filter`

__Class__: `filter.dfilt` or `[]`

__Default__: `[]`

The low-level filter object that implements the filtering operator. See the
documentation of the [filter package][filter-pkg] for a list of available 
filters and instructions for defining your own filters.

[filter-pkg]: https://github.com/germangh/matlab_filter/tree/master/+filter/README.md


### `ChopSelector`

__Class__: `physioset.event.selector`

__Default__: `[]`

This event selector object will be used to select the subset of data events
that define the data analysis windows. The filtering operation will then 
be performed on each analysis window separately.


### `ExpandBoundary`

__Class__: `1x2 numeric array`

__Default__: '[2 2]'

The length of the boundary expansions to minimize boundary effects. The 
length of the left expansion boundary and right expansion boundary is 
specified as percentage of the corresponding analysis window. That is, the
default setting for `ExpandBoundary` will use a left and right expansion 
boundaries of the same length and equal to 2% of the length of the 
corresponding analysis window.


### `ReturnResiduals`

__Class__: `logical scalar`

__Default__: `false`

If set to `true` the output of the node will be the difference between the
low-level filter output and the input data. The default `false` setting 
produces a node output identical to the output of the low-level filter. 


### `NbChannelsReport`

__Class__: `numeric scalar`

__Default__: `10`

The number of data channels to plot in the generated report.



### `EpochDurReport`

__Class__: `numeric scalar`

__Default__: `50`

The duration of the epochs to be plotted in the output report, in seconds. 
Use `Inf` to indicate that the whole analysis window should be plotted.


### `ShowDiffReport`

__Class__: `logical scalar`

__Default__: `false`

If set to `true` the report images will display the input to the node 
versus the difference between the input and the output of the node. The 
default behavior (`ShowDiffReport = false`) is to plot the input to the 
node versus the node output.