`var` criterion class
===

The fully qualified name of this class is
`meegpipe.node.bad_channels.criterion.var`. For brevity we refer to it as the
`var` class in this document. The `var` criterion rejects channels that have
abnormally low or high variance. The behavior of the `var` criterion can be
tuned using various configuration properties (see below).

## Construction

	import meegpipe.node.bad_channels.criterion.*;
	myCrit = var.new('Option1', 'val1', ...)



## Configuration options

The `var` criterion accepts all the configuration options accepted by the
parent [rank][rank] criterion. Additionally, it accepts all the configuration
options defined by the associated [config][config] class. Configuration options
can be set either during construction of the criterion object:

    import meegpipe.node.bad_channels.criterion.*;
    myCrit = var.new('NN', 5);

or after construction using method `set_config`:

    myCrit = meegpipe.node.bad_channels.criterion.var.new;
    set_config(myCrit, 'NN', 10);

[config]: ./config.md
[rank]: ../+rank/README.md

You can also retrieve configuration options using method `get_config`:

    nn = get_config(myCrit, 'NN');


## Default configurations

### `zscore`

The `zscore` configuration normalizes each data column (time instant) 
using MATLAB's built-in `zscore` before computing the channel variances.
To use this default configuration:

````matlab
import meegpipe.node.*;
myCrit = bad_channels.criterion.var.zscore;
myNode = bad_channels.new('Criterion', myCrit);
````

For more details on the `zscore` configuratin see [zscore.m][zscore]. 

[zscore]: ./zscore.m


## Usage examples

See the documentation of the [bad_channels][badchans] node for usage examples.

[badchans]: ../../README.md
