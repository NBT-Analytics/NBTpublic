`bad_epochs` criterion class
===

Reject data channels that lead to epoch rejection (according to a given 
epoch rejection criterion). 

## Construction

````matlab
import meegpipe.node.*;
myCrit = bad_channels.criterion.bad_epochs.new('Option1', 'val1', ...)
````


## Configuration options

The behavior of this criterion can be modified using various configuration
 options, which can be set either during construction of the
 criterion object:

````matlab
import meegpipe.node.*;
myCrit = bad_channels.criterion.bad_epochs.new('Max', 0.25);
````

or after construction using method `set_config`:

````matlab
import meegpipe.node.*;
myCrit = bad_channels.criterion.bad_epochs.new
set_config(myCrit, 'Max', 0.25);
````

For a complete list of valid configuration options and their effect, see
the documentation of the helper [config][config] class.

[config]: ./config.md


## Usage examples

### Example 1

We aim to compute an ERP based on all events of type `stm` that are 
embedded in a physioset object. In this hypothetical scenario it makes 
sense to reject all those channels which would otherwise lead to more than 
(say) 50% of the available `stm` epochs being rejected due to the epochs
exceeding the maximum threshold used by a subsequent 
[bad_epochs node][bad_epochs]. We can implement this channel rejection 
strategy using the code snippet below:

[bad_epochs]: ../../../+bad_epochs/README.md

```matlab
import meegpipe.node.*;

% An epoch rejection criterion, used later in a bad_epochs node
% This criteiron will reject any epoch that exceeds 100 or -100 microvolts
% in any channel
myBadEpochsCrit = bad_epochs.criterion.stat.new('Max', 100, 'Min', -100);

% The event selector that selects the events relevant for ERP computation
myEvSel = physioset.event.class_selector('Type', 'stm');

% Build a bad_channels rejection criterion that will reject all those 
% channels that would otherwise lead to more than 50% of epochs being 
% rejected at the bad_epochs node that follows
myBadChansCrit = bad_channels.criterion.bad_epochs.new(...
    'BadEpochsCriterion',   myBadEpochsCrit, ...
    'Max',                  0.5, ...
    'EventSelector',        myEvSel);

% Build the bad_channels node
myNode = bad_channels.new('Criterion', myBadChansCrit);
```


