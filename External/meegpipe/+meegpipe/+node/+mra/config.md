CONFIG - Configuration for node mra
======

This class is a helper class that implements consistency checks
necessary for building a valid mra node. 

## Usage synopsis:

Create an mra node that will create a template by averaging the
the last 20 volume artifact repetitions, assume `TR=3000 ms`:

````matlab
import meegpipe.node.mra.*;
myConfig = config('NN', 20, 'SearchWindow', [20*3000 0], 'TR', 3000);
myNode   = mra(myConfig);
````

The following syntax is completely equivalent:

````matlab
import meegpipe.node.mra.*;
myConfig = config('NN', 20, 'SearchWindow', [20*3000 0], 'TR', 3000);
myNode   = mra(myConfig);
````

## Configuration properties

The following construction options are accepted by the constructor of 
this config class, and thus by the constructor of the mra class:

### EventSelector

__Class__ : pset.event.selector

__Default__ : ````physioset.event.class_selector('tr')````

The event selector to use for selecting TR events among the list of
events associated to a physioset.


### LPF

__Class__ : positive scalar

__Default__ : ````40````

The cutoff of the post-processing low-pass filter. If left empty no
post-processing filtering will be performed.


### NbSlices

__Class__ : natural scalar

__Default__ : ````1````

The number of slice artifacts to consider within a TR. If you set
this value to 1 then a single template will be built for a volume. If
you set this value to the number of actual slices within a volume
then a template will be built for each slice artifact. The latter has
the advantage of having many more degrees of freedom for removing MR
artifacts, but it is often not very robust. In general you will not
want to modify the default value of this construction parameter.

### NN

__Class__ : natural scalar

__Default__ : ````20````

The number of artifact instances to use for building the template.


### SearchWindow

__Class__ : 1x2 vector of natural numbers

__Default__ : ````[300 300]````

The search window in seconds from which artifact instances will be
extracted in order to build an artifact template. The first and
second element of SearchWindow correspond to the extent of the search
window towards the past and future, respectively.


### TemplateFunc

__Class__ : function_handle

__Default__ : ````@(x) mean(x,2)````

The funtion_handle that will be used to compute the template basis
functions from the matrix of selected artifact instances. Apart from
the default, another reasonable choice is ````@(x) spt.fast_pca(x', 3)````,
which will use as template basis the first three principal components
of the artifact realizations.

