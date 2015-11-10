`rank` criterion class
===

The `rank` criterion for bad epochs rejection is an abstract criterion
designed for inheritance. That means that you cannot create instances of
this criterion class, but you may use it as a scheleton for defining your
own custom criteria. Any criterion that inherits from the `rank` criterion
accepts the configuration options listed below.


## Configuration options

All criteria classes that inherit from the `rank` criterion accept the
following configuration options:


### `MinCard`

__Class:__ `numeric` scalar or `function_handle`

__Default:__ `0`

The minimum number of epochs that will be rejected. If set to a
`function_handle` the minimum number of epochs that will be rejected
will be obtained by evaluating `MinCard` on the array of rank values for
all epochs. That is, to ensure that at least 10% of epochs are
rejected you could set `MinCard` to `@(rankVal) ceil(0.1*numel(rankVal))`.


### `MaxCard`

__Class:__ `numeric` scalar or `function_handle`

__Default:__ `@(rankVal) ceil(0.2*numel(rankVal))`


The maximum number of epochs that will be rejected. If set to a
`function_handle` the maximum number of epochs that will be rejected
will be obtained by evaluating `MaxCard` on the array of rank values for
all epochs. That is, to ensure that at most 50% of epochs are
rejected you could set `MaxCard` to `@(rankVal) floor(0.5*numel(rankVal))`.


### `Min`

__Class:__ `numeric` scalar or `function_handle`

__Default:__ `@(x) median(x)-10*mad(x)`

The lower rank value threshold below which an epoch will be rejected. If
`Min` is set to a `function_handle`, then the actual lower threshold will
be obtained by evaluating `Min` on the array of rank values for all
epochs. That is, to ensure that those epochs whose rank value is 10
or more median absolute deviations below the median you should set `Min`
to `@(rankVal) median(rankVal)-10*mad(rankVal)`.


### `Max`

__Class:__ `numeric` scalar or `function_handle`

__Default:__ `@(x) median(x)+10*mad(x)`

The upper rank value threshold above which an epoch will be rejected.


### `RankPlotStats`

__Class:__ `mjava.hash` or `[]`

__Default:__ `meegpipe.node.bad_epochs.criterion.rank.default_plot_stats`

A dictionary containing various statistics to be plotted together with the 
epoch statistic in the generated HTML report. For instance, you may create
the following `bad_epochs` node:

````
import meegpipe.node.*;
import meegpipe.node.bad_epochs.criterion.*;

myStats = mjava.hash;    % Initialize the dictionary of statistics
myStats('5%')         = @(x) prctile(x, 5);
myStats('95%')        = @(x) prctile(x, 95);
myStats('median')     = @(x) median(x);
myStats('mean')       = @(x) mean(x);
myStats('median-mad') = @(x) median(x) - mad(x);
myStats('median+mad') = @(x) median(x) + mad(x);

myCrit = stat.new('RankPlotStats', myStats);

myNode = bad_epochs.new('Criterion', myCrit);

````
