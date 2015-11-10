`abp_features` - Extract features from ABP time-series
===

The `abp_features` node extracts [well-known features][features] from 
Arterial Blood Pressure time-series. This node expects the present of 
`abp_onset` events in the input physioset, marking the locations of the 
beat onsets in the ABP time-series. You can generate the latter using an
[abp_beat_detect][abp_beat_detect] node.

[abp_beat_detect]: ../+abp_beat_detect/README.md
[features]: http://www.physionet.org/physiotools/cardiac-output/


## Usage synopsis:

````matlab
import meegpipe.*;
obj = node.abp_features.new('key', value, ...)
run(obj, data);
````

where `data` is a [physioset][physioset] object.

[physioset]: https://github.com/germangh/matlab_physioset/blob/master/%2Bphysioset/%40physioset/README.md
abp_features