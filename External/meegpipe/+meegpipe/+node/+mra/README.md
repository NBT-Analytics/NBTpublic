mra - MR gradient artifact removal node
====

The `mra` node can be used to remove MR scanning artifacts using
a simple template removal algorithm. 

## Usage synopsis

````matlab
import meegpipe.*;
obj = node.mra.new('key', value, ...);
data = run(obj, data);
````

where `data` is a physioset object.


## Construction arguments (as key/value pairs):

The mra node admits all the key/value pairs admitted by the
[abstract_node][abstract-node] class. For keys specific to this node
class see the documentation of the helper [config][config] class.

[abstract-node]: ../@abstract_node
[config]: ./config.md


## Methods

See the documentation of the [node API documentation][node].

[node]: ../

