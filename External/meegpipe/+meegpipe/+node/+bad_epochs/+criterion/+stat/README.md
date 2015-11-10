`stat` criterion for bad epochs rejection
===

The fully qualified name of this class is
`meegpipe.node.bad_epochs.criterions.stat`. For brevity we refer to it as the
`stat` class in this document. The `stat` criterion characterizes each data
epoch using a scalar statistic. Epochs with extreme statistic values are
then rejected using user-defined thresholds.


## Construction

````matlab
import meegpipe.node.*;
myCrit = bad_epochs.criterion.stat.new('key', value, ...)
````


## Configuration options

The `stat` criterion accepts all the configuration options accepted by the
parent [rank][rank] criterion. Additionally, it accepts all the configuration
options defined by the associated [config][config] class.


[rank]: ../+rank/README.md
[config]: ./config.md

