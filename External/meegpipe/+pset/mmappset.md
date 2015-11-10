`mmappset` interface
================

The `mmappset` interface provides basic operations for data structures 
that rely on memory-mapped disk files. Examples of such classes are the 
[physioset][physioset-class] and [pset][pset-class] classes.

[physioset-class]: https://github.com/germangh/matlab_physioset/tree/master/+physioset/@physioset
[pset-class]: ./%40pset

## Interface methods

This is still on the making.

### concatenate()

Create a physioset object by concatenating two or more physioset objects.

````matlab
obj = concatenate(varargin);
````

### copy()

Create a copy of a physioset object. The new object will be associated to 
a new memory-mapped disk file.

````matlab
newObj = copy(obj, varargin);
````

### get_datafile()

Get the full path name of the disk file holding the associated 
memory-mapped file.

````matlab
 filename = get_datafile(obj);
````

### get_hdrfile()

Get the full path to the associated header file.

````matlab
 filename = get_hdrfile(obj);
````

### nb_dim(), nb_pnt()

Number of data dimensions and number of data points contained in the 
physioset.

````matlab
nDims = nb_dim(obj);
nPnts = nb_pnt(obj);
````

### subsasgn()

````matlab
obj = subsasgn(obj, s, b);
````

### save()

Save physioset object to disk file. Note that all physioset 
objects are associated to a (memory-mapped) disk file. However, clearing 
all references to a physioset object in the MATLAB workspace will 
automatically trigger the deletion of the associated file. Method 
`save()` prevents this from happening and stores a copy of the 
physioset object in a header file. 

````matlab
save(obj, filename);
````

### subset

Create a new physioset from a subset of another physioset.

````matlab
newObj = subset(obj, varargin);
````

### subsref

````matlab
values  = subsref(obj, s);
````

