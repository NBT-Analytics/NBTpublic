`physioset` method `subset`
===

Method `subset` creates a `physioset` object as a subset of another 
`physioset` object.

## Usage

````matlab
objNew = subset(obj, rowIdx, colIdx);
objNew = subset(obj, mySel);
objNew = subset(obj);
````

Where

`obj` is a `physioset` object, `rowIdx` is an array of row (channel)
indices, `colIdx` is an array of column (sample) indices, `mySel` is a 
`selector` object, and `objNew` is a `physioset` object created from a 
subset of the data contained in `obj`.

The second usage example above will apply the provided selector on the
input `physioset` and, subsequently, will build `objNew` using the
selected subset of `obj`.

The third usage example above will create `objNew` using the current
selection of `obj`. If no selections have been applied to `obj` then 
`objNew` will simply be a copy of `obj`.

## More information

* Class [physioset.physioset][physioset]
* Interface [pset.selector.selector][selector-ifc]
* Package [pset.selector][selector-pkg] contains several commonly used 
  `selector` classes.

[physioset]: ../README.md
[selector-ifc]: https://github.com/germangh/matlab_pset/tree/master/+pset/+selector/selector.md
[selector-pkg]: https://github.com/germangh/matlab_pset/tree/master/+pset/+selector/README.md
