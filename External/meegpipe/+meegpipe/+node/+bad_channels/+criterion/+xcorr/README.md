`xcorr` criterion class
===

The fully qualified name of this criterion class is
`meegpipe.node.bad_channels.criterion.xcorr`. For brevity we refer to this class
as the `xcorr` class in this document. The `xcorr` criterion rejects channels
having low cross-correlation with neaghboring channels. The behaviour of the
criterion can be tuned using various configuration options (see below).

## Construction

    import meegpipe.node.bad_channels.criterion.*;
    myCrit = xcorr.new('Option1', value1, ...)


## Configuration options

The `xcorr` criterion accepts all the configuration options accepted by the
parent [rank][rank] criterion. Additionally, it accepts all the configuration
options defined by the associated [config][config] class. Configuration options
can be set either during construction of the criterion object:

    import meegpipe.node.bad_channels.criterion.*;
    myCrit = xcorr.new('NN', 5);

or after construction using method `set_config`:

    myCrit = meegpipe.node.bad_channels.criterion.var.new;
    set_config(myCrit, 'NN', 10);

You can also retrieve configuration options using method `get_config`:

    nn = get_config(myCrit, 'NN');



[config]: ./config.md
[rank]: ../+rank/README.md


## Usage examples

See the documentation of the [bad_channels][badchans] node for usage examples.

[badchans]: ../../README.md
