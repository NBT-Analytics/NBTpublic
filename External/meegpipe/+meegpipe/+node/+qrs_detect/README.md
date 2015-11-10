`qrs_detect` - Detection of QRS complexes from ECG time-series
===

The `qrs_detect` node detects QRS complexes and introduces suitable events
at the occurrence times of such complexes. 


## Usage synopsis:

````matlab
import meegpipe.*;
obj = node.qrs_detect.new('key', value, ...)
run(obj, data);
````

where `data` is a [physioset][physioset] object.

[physioset]: https://github.com/germangh/matlab_physioset/blob/master/%2Bphysioset/%40physioset/README.md
