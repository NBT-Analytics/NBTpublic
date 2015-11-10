`abstract_node`
========

The `abstract_node` class is an [abstract class][absvsconcr] designed for 
[inheritance][inheritance-oop]. This means that you cannot explicitely 
create instances of this class, but instead the purpose of `abstract_node`
is to provide its children [node classes][node-ifc] with common properties
and methods. 

[node-ifc]: ../README.md
[absvsconcr]: https://en.wikipedia.org/wiki/Class_(computer_programming)#Abstract_and_Concrete

We usually refer to the common set of properties defined by class 
`abstract_node` as _node properties_. On the other hand, each [concrete][absvsconcr] 
node class (i.e. a child class to `abstract_node`) may define an additional
set of properties (not shared with other concrete `node` classes). We
usually refer to the latter set of properties as node
_configuration options_. 

This document deals only with the set of generic _node properties_ defined 
by `abstract_node`. For information regarding _configuration options_ we
refer you to the documentation of the specific `node` class. For further 
information on the organization and class hierarchy of `node` classes, see
the documentation of the [node API][node-ifc].


[inheritance-oop]: http://en.wikipedia.org/wiki/Inheritance_(object-oriented_programming)
 

## Construction arguments

The following arguments are accepted by the constructor of the 
`abstract_node` class as key/value pairs. These keys define the set of 
_node properties_ which are accepted by the constructors of all `node` 
classes. 

### `DataSelector`

__Class__: `pset.selector.selector`

__Default__: `[]`


The `DataSelector` property allows to specify that the node should process
only a custom subset of the input data. For instance, you may build a 
[bss_regr][bss_regr] node that will processed only EEG data, and that will
ignore bad data channels and bad data samples:

[bss_regr]: ../+bss_regr/README.md

````matlab
% First we build a good data selector
mySel1 = pset.selector.good_data;
% Then a selector of EEG data
mySel2 = pset.selector.sensor_class('Class', 'EEG');

% Our selector is a combination of the two above
mySel = pset.selector.cascade(mySel1, mySel2);

% We can now provide mySel to the constructor of the bss_regr node
myNode = meegpipe.node.bss_regr.new('DataSelector', mySel);
````


### `GenerateReport`

__Class__: `logical`

__Default__: `true`

If `GenerateReport` is set to `false`, only a minimalistic HTML report will
be generated after every data processing job carried out by the node. Note 
that the generation of HTML reports cannot be completely deactivated 
because such reports are necessary for reproducibility purposes. However, 
if `GenerateReport` is `false`, the overhead due to the generation of the 
the HTML reports should be minimal. 


### `Name`

__Class__: `char`

__Default__: `class(obj)`

A string identifying a concrete node instance. This node `Name` will be 
used to refer to the node within the generated HTML reports, as well as 
in the status messages printed to the MATLAB console. It is a good
idea to use descriptive and short node names. Using very long node names 
may lead to long path names in the generated HTML reports, which 
may cause [problems under Windows][maxpath].

[maxpath]: http://msdn.microsoft.com/en-us/library/aa365247%28VS.85%29.aspx#maxpath


### `OGE`

__Class__: `logical`

__Default__: `true`

If set to true, the node will attempt to submit all processing jobs to the
[Oracle Grid Engine (OGE)][oge] middleware. If the OGE middleware is 
available, this will allow for parallel processing of multiple datasets. 
Moreover, OGE offers lots of options for flexible job and load management 
in shared computing environments. 

If you want to find out whether OGE is available in your system (and it is
properly configured for _meegpipe_ to use it) run:

````matlab
oge.has_oge
````

If the result is `true` then OGE is available.

[oge]: http://www.oracle.com/us/products/tools/oracle-grid-engine-075549.html


### `Queue`

__Class__: `char`

__Default__: `long.q`

The OGE queue to which the processing jobs will be submitted (if OGE is 
available, and if the node property `OGE` is set to `true`).


### `Save` 

__Class__: `logical`

__Default__: `false`

If set to true the data processed by the node will be saved to a 
(permanent) disk file. If set to false, the processed 
[physioset][phys-class] will be _temporary_ and as such, any associated 
disk file will be automatically deleted when all references to the 
`physioset` object have been cleared from MATLAB's workspace.

[phys-class]: http://github.com/germangh/matlab_physioset/blob/master/+physioset/@physioset/README.md
