`physioset` method `merge`
===

Merge two or more physioset objects by concatenating them in time

## Usage

````matlab
obj = merge(obj1, obj2, ...)
````

where

`obj1`, `obj2`, ... are `physioset` objects

`obj` is the `physioset` object that results of concatenating `obj1`, 
`obj2`, ... in time.


## Accepted (optional) key/value pairs

### `Path` 

__Class__: `string`

__Default__: `''`

The path to the directory where the copy of the new memory-mapped file
 should be created. If left empty, the path of the generated file will 
be the same as that of the first input `physioset` object.


### `DataFile`

__Class__: `string`

__Default__: `''`

The name of the newly created memory-mapped file.


### `Prefix`

__Class__: `string`

__Default__: `''`

The name of the memory-mapped file will be obtained by adding this prefix
 to the name of the memory-mapped file associated to the first input 
physioset. 


### `Postfix`

__Class__: `string`

__Default__: `''`

Same as `Prefix` but specifies as postfix.


### `Overwrite`

__Class__: `logical`

__Default__: `false`

If set to true, the memory-mapped file will be created even if it already
 exists. Otherwise, if the file already exists an error will be triggered. 