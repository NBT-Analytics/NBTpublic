`ecg_annotate` - Annotate ECG heartbeats
===

The `ecg_annotate` node annotates heartbeats
using [ecgpuwave][ecgpuwave]. This node is actually a wrapper to the public
`ecgpuwave` implementation in MATLAB by [Pablo Laguna][laguna] and others. This
node expects R-peak locations to be annotated using appropriate events in the
input physioset. Suck R-peak locations can be detected and annotated using
a [qrs_detect][qrs_detect] node.

[qrs_detect]: ../+qrs_detect/README.md

Additionally, the `ecg_annotate` node computes heart rate variability features
based on the annotations produced by `ecgpuwave`. This is done using the
[HRV Toolkit][hrv_toolkit]. The HRV features are stored in a log file 
(`features.txt`) contained within the node's report directory, and easily
accessible through the node's HTML report.

[hrv_toolkit]: http://physionet.org/tutorials/hrv-toolkit/
[physionet]: http://physionet.org/


## Dependencies

Node `ecg_annotate` depends of several Linux command-line utilities. If you 
are using `ecg_annotate` in Windows, then you will need to install 
[Cygwin][cygwin] and start MATLAB from a Cygwin terminal window so that all
built-in Cygwin utilities become accessible to MATLAB through the 
`system()` command. 

[cygwin]: http://www.cygwin.com/

The following third-party software needs to be installed in your Linux-like 
system for node `ecg_annotate` to work:

* [Physionet's WFDB][wfdb]

* [Physionet's HRV toolkit][hrv_toolkit]

[wfdb]: http://www.physionet.org/physiotools/wfdb.shtml

If you are working at `somerengrid` (the private computing grid used by our
[research group][sc]) then all third-party dependencies should be already
there, and you node `ecg_annotate` should work out of the box.
TALL

[ecgpuwave]: http://www.physionet.org/physiotools/ecgpuwave/
[laguna]: http://diec.unizar.es/~laguna/personal/



## Usage synopsis:

````matlab
import meegpipe.*;
obj = node.ecg_annotate.new('key', value, ...)
run(obj, data);
````

where `data` is a [physioset][physioset] object.

[physioset]: ../../../+physioset/@physioset/README.md

## Construction arguments

The `ecg_annotate` node admits all the key/value pairs admitted by the
[abstract_node][abstract-node] class. For configuration options specific to
this node class see the documentation of the helper [config][config] class.

[abstract-node]: ../@abstract_node/README.md
[config]: ./config.md


## Methods

See the documentation of the [node API documentation][node].

[node]: ../


