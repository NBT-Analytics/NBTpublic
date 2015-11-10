`config` for node `ev_gen`
===

This class is a helper class that implements consistency checks necessary for
building a valid [ev_gen][ev_gen] node.

[ev_gen]: ./README.md


## Usage synopsis

Add periodic events every 15 seconds of type `myevent` to the input 
physioset:

````matlab
% The event generator object that will actually generate the events
myGen = physioset.event.periodic_generator(...
    'Period',   15, ...
    'Type',     'myevent');
myNode = ev_gen.new('EventGenerator', myGen);
run(myNode, data);
````

where `data` is a `physioset` object.


## Configuration properties


The following construction options are accepted by the constructor of
this config class, and thus by the constructor of the `ev_gen` node class:

### `EventGenerator`

__Class__: `physioset.event.generator`

__Default__: `physioset.event.periodic_generator`


The event generator object that will take care of generating the events. 
The default genenerator will generate periodic events every 10 seconds of 
type `__PeriodicEvent`.
