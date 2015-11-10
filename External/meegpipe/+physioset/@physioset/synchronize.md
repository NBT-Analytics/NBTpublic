`physioset` method `synchronize`
=====

Synchronize and resample physioset objects

## Usage

````matlab
obj = synchronize(obj1, obj2, ...)
obj = synchronize(obj1, obj2, obj3, ..., 'policy')
obj = synchronize(obj1, obj2, obj3, ..., 'policy', 'key', value, ...)
````

where `obj1`, `obj2`, ... are a set of `physioset` objects containing
measurements that were simultaneously acquired but possibly at different
sampling rates or in general at non-overlapping sampling instants.

`policy` is a string identifying the synchronization policy. This
argument is equivalent to the `synchronizemethod` argument taken by
method [synchronize][matlab-sync] of MATLAB's built-in 
[timeseries][timeseries] objects.

[matlab-sync]: http://www.mathworks.nl/help/matlab/ref/timeseries.synchronize.html
[timeseries]: http://www.mathworks.nl/help/matlab/ref/timeseriesclass.html

`obj` is the result of synchronizing (possibly resampling) the set of
input physiosets.

## Optional arguments

The following arguments can be optionally provided as key/value pairs:

### `FileNaming`

__Class__: `char`

__Default__: `inherit`

The policy for determining the name of the disk file that will hold the 
synchronized `physioset` values. 

### `FileName`

__Class__: `char`

__Default__: `[]`

If provided and not empty, this file name will be used as the destination
of the synchronized `physioset`. Note that this argument overrides argument
`FileNaming`.

### `InterpMethod`

__Class__: `char`

__Default__: `linear`

The interpolation method to use. See the documentation of MATLAB's 
built-in [interp1][interp1] function for a list of supported interpolation 
methods.

[interp1]: http://www.mathworks.nl/help/matlab/ref/interp1.html

### `Verbose`

__Class__: `logical`

__Default__ : `true`

If set to false, the operation of `synchronize` will not produce any 
status messages.



## Examples

### Just resampling

Synchronize two physiosets with common start times but different sampling
rates:

````matlab
import physioset.import.matrix;
timeOrig = now;
% Sampled at 10 Hz
pObj1 = import(matrix(10, 'StartTime', timeOrig), randn(2,10));
% Sampled at 100 Hz
pObj2 = import(matrix(100, 'StartTime', timeOrig), randn(2,100));
% Sampled at 1000 Hz
pObj3 = import(matrix(1000, 'StartTime', timeOrig), randn(1,1000));
% Synchronize them
pObj = synchronize(pObj3, pObj2, pObj1, 'union');
````

### Resampling and synchronizing

Synchronize three physiosets with overlapping sampling times and
different sampling rates:

````matlab
import physioset.import.matrix;
timeOrig1 = now;
secsPerDay = 24*60*60;
timeOrig2 = timeOrig1 - 10/secsPerDay;
timeOrig3 = timeOrig1 + 10/secsPerDay; 

% Sampled at 10 Hz
pObj1 = import(matrix(10, 'StartTime', timeOrig1), randn(2,20*10));
% Sampled at 100 Hz
pObj2 = import(matrix(100, 'StartTime', timeOrig2), randn(2,25*100));
% Sampled at 1000 Hz
pObj3 = import(matrix(1000, 'StartTime', timeOrig3), randn(1,25*1000));
% Add some dummy events for test purposes
import physioset.event.event;
ev = event(100, 'Type', 'firstEv'); 
add_event(pObj1, ev);
ev = event(110, 'Type', 'secondEv');
add_event(pObj1, ev);
ev = event(1000, 'Type', 'thirdEv');
add_event(pObj3, ev);

% Synchronize them
pObj = synchronize(pObj3, pObj2, pObj1);
````
