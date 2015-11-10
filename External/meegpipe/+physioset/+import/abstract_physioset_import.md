abstract_physioset_import
========

The `abstract_physioset_import` class is an abstract class designed for
inheritance. This means that instances of the class cannot be created
but instead the purpose of the class is to provide its children
classes with common properties and methods. The values of the
properties listed below can be set during construction of an object
of a child class using key/value pairs. For instance, the command:

````matlab
importObj = physioset.import.matrix('Temporary', true, 'Writable', false)
````

will create an importer object of class `matrix` (a child class of class 
`abstract_physioset_import`). The property `Temporary` and `Writable` 
properties (both defined by the `abstract_physioset_import` class) will be
set to `true` and `false`, respectively.


## Construction arguments

The following optional arguments can be provided during construction
as key/value pairs.


### `Precision`

__Class__: `char`

__Default__: `pset.globals.get.Precision`

The numeric precision that should be used when importing data. 


### `Writable`

__Class__: `logical` 

__Default__: `pset.globals.get.Writable`

If set to `true` the generated object will be _writable_, in the
sense that the contents of its associated memory map can be modified
through its public API. For instance:

````matlab
importer = physioset.import.matrix('Writable', false);
obj = import(importer, randn(10,1000));
obj(1,1) = 0; % Not allowed
obj.Writable = true;
obj(1,1) = 0; % Now it is allowed
````

### `Temporary`

__Class__: `logical`

__Default__: `pset.globals.get.Temporary`

If set to true, the associated memory map and header file will be
deleted once all references to the `pset` object have been cleared
from MATLAB's workspace.

### `FileNaming`

__Class__: `char`

__Default:__ `'inherit'`

Either `'Inherit'`, `'Random'`, or `'Session'`. See the documentation
of [pset.file_naming_policy][file-naming-policy] for more
information.


### `ReadEvents`

__Class__: `logical`

__Default:__ `true`

If set to true, the events information will also be imported. This
can slow down the data import considerably in some cases. Not all
data importers take into consideration the value of this property,
i.e. events may be imported even if `ReadEvents` is set to `false`.


### `StartTime`

__Class__: `double`

__Default__: `now`

The time origin for the `physioset` sampling instants. The absolute 
sampling instant for the `i`th sample of a `physioset` object `obj` can be
obtained using:

````matlab
samplTime = sampling_time(obj);
itime = addtodate(get_time_origin(obj), 
````
