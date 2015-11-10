`criterion` interface
===

The fully qualified name of this interface is
`meegpipe.node.bad_epochs.criterion.criterion`. For brevity we refer to it
in this document as the `criterion` interface. All bad epochs rejection
criteria must implement this interface, including
[user-defined criteria][userdef].

[userdef]: ./README.md

## Methods

### `find_bad_epochs`

Find bad epochs from data matrix or from a [pset][pset] or [physioset][phys]
object.

[pset]: https://github.com/germangh/matlab_pset/tree/master/%2Bpset/%40pset/README.md
[phys]: https://github.com/germangh/matlab_physioset/blob/master/%2Bphysioset/%40physioset/README.md

````matlab
[idx, rankVal] = find_bad_epochs(obj, data)
````

Where

`data` is a data matrix, or an object that behaves as such, e.g. a `pset` or
`physioset` object.

`idx` is an array of natural indices corresponding to the epochs that were
identified as bad.

`rankVal` is a numeric array with as many elements as rows has the input
`data`. For each `data` row (or channel), the corresponding entry of
`rankVal` contains the assigned rank value by the bad channel selection
criterion. Extreme rank values increase the chance of an epoch being 
rejected.

