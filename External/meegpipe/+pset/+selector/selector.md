selector
===

Interface for data selector classes

## Interface methods

### `not`

Method `not` can be used to produce an _inverted_ selector, i.e. a
selector that will select the set of data complementary to the set
that would be selected by the original selector.

````matlab
objInv = not(obj)
````

### `select`

Method `select` is the main interface method. It takes a `physioset`
or `pset` object (`data`) as second argument, on which the data
selection is performed.

````matlab
select(obj, data)
````



See also: pset
