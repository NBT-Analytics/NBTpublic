`merge` - Merge data files
====

`merge` nodes create a single physioset object by merging the contents of
multiple disk files.


## Usage synopsis

Merge files `file1.mff` and `file2.mff`: 

````matlab
import meegpipe.node.*;

myNode = merge.new('Importer', physioset.import.mff);
data = run(myNode, {'file1.mff', 'file2.mff'});
````


## Construction arguments

The `merge` node admits all the key/value pairs admitted by the
[abstract_node][abstract-node] class. For keys specific to this node
class see the documentation of the helper [config][config] class.

[abstract-node]: ../@abstract_node/README.md
[config]: ./config.md


## Methods

See the documentation of the [node API documentation][node].

[node]: ../


## Usage examples

The example below assume that _meegpipe_ has been initialized using:

````matlab
clear all;
meegpipe.initialize;
````


### Merge files that have different data formats

````matlab
import meegpipe.node.*;

myNode = merge.new('Importer', ...
    { ...
    physioset.import.mff, ...
    physioset.import.edfplus, ...
    physioset.import.mff ...
    });

data = run(myNode, {'file1.mff', 'file2.edf', 'file3.edf'});
````

