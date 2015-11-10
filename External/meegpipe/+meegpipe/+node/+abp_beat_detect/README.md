`abp_beat_detect` - Detection of beat onsets from ABP measurements
===

The `qrs_detect` node detects beat onsets from Arterial Blood Pressure 
measurements generates `abp_beat` events at the occurrence times of such
 complexes. 


## Usage synopsis:

````matlab
import meegpipe.*;
obj = node.abp_beat_detect.new('key', value, ...)
run(obj, data);
````

where `data` is a [physioset][physioset] object.

[physioset]: https://github.com/germangh/matlab_physioset/blob/master/%2Bphysioset/%40physioset/README.md
