`aregr` - (Adaptive) regression
===

The `aregr` node can be used to regress a subset of channels from another subset
of channels.

## Usage synopsis:

````matlab
import meegpipe.*;
obj = node.aregr.new('key', value, ...)
run(obj, data);
````

where `data` is a [physioset][physioset] object.

[physioset]: https://github.com/germangh/matlab_physioset/blob/master/%2Bphysioset/%40physioset/README.md


## Construction arguments

The `aregr` node admits all the key/value pairs admitted by the
[abstract_node][abstract-node] class. For configuration options specific to this
node class see the documentation of the helper [config][config] class.

[abstract-node]: ../@abstract_node/README.md
[config]: ./config.md


## Methods

See the documentation of the [node API documentation][node].

[node]: ../


