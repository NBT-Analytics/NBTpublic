meegpipe
========

_meegpipe_ is a collection of MATLAB tools for building advanced processing
pipelines for high density physiological recordings. It is especially
suited for the processing of high-density [EEG][eeg] and [MEG][meg],
but can also handle other modalities such as [ECG][ecg], temperature,
[actigraphy][acti], light exposure, etc.


[gg]: https://groups.google.com/forum/#!forum/meegpipe
[ggh]: http://germangh.com
[eeg]: http://en.wikipedia.org/wiki/Electroencephalography
[meg]: http://en.wikipedia.org/wiki/Magnetoencephalography
[ecg]: http://en.wikipedia.org/wiki/Electrocardiography
[acti]: http://en.wikipedia.org/wiki/Actigraphy


## Pre-requisites (third-party dependencies)

If you are working at somerengrid (our lab's private computing grid), then
all the pre-requisites are already there and you can go directly to the
installation instructions.


### EEGLAB

[EEGLAB][eeglab] is required mostly for input/output of data from/to
 various data formats, and for plotting. Please ensure that EEGLAB is in
your MATLAB search path.

[meegpipecfg]: http://github.com/meegpipe/meegpipe/blob/master/%2Bmeegpipe/meegpipe.ini
[ftrip]: http://fieldtrip.fcdonders.nl/
[eeglab]: http://sccn.ucsd.edu/eeglab/
[fileio]: http://fieldtrip.fcdonders.nl/development/fileio
[matlab-package]: http://www.mathworks.nl/help/matlab/matlab_oop/scoping-classes-with-packages.html

### Highly recommended dependencies

The engine responsible for generating data processing reports in HTML
relies on several Python packages and on [Inkscape][inkscape]. _meegpipe_ will
 be fully functional without these dependencies, but the processing reports
will be generated in a plain text format (using [Remark][remark] syntax).
Inspecting plain text reports with embedded images is _very inconvenient_
so please consider installing these [highly recommended dependencies][recommended-dep].

[remark]: http://kaba.hilvi.org/remark/remark.htm
[recommended-dep]: https://github.com/meegpipe/meegpipe/blob/master/recommended.md
[inkscape]: http://www.inkscape.org/en/


### Optional

You are encouraged to install a few [additional components][optional] that
can enhance _meegpipe_'s functionality in terms of
[high-throughput computing][ht-comp].


[ht-comp]: http://en.wikipedia.org/wiki/High-throughput_computing
[optional]: https://github.com/meegpipe/meegpipe/blob/master/optional.md
[gc]: http://www.google.com/chrome



## Installation

Before attempting to install _meegpipe_, please make sure that all the 
relevant dependencies have been already installed on your system. Then, 
copy and paste the following code in the MATLAB command window:

````matlab
% installDir is your installation directory
installDir = [pwd filesep 'meegpipe'];
url = 'https://github.com/meegpipe/meegpipe/archive/v0.1.9.zip';
unzip(url, installDir);
addpath(genpath('meegpipe'));
meegpipe.initialize;

% Initialize meegpipe every time that MATLAB starts
addpath(userpath);
fid = fopen(which('startup'), 'a');
fprintf(fid, [...
    '%%Added by meegpipe (http://germangh.com/meegpipe)' ...
    '\naddpath(genpath(''%s''));' ...
    '\nmeegpipe.initialize;\n'], installDir);
fclose(fid);
````

Notice that the code above will install _meegpipe_ in directory `meegpipe`
under your current working directory. Notice also that EEGLAB needs to be
part of your MATLAB search path for the `meegpipe.initialize` command to
 succeed. This means that you either add EEGLAB permanently to your MATLAB
search path, or you add the following command to your `startup.m` file,
before the `meegpipe.initialize` command:

````matlab
addpath(genpath('/path/to/your/eeglab/installation'));
````


## Basic usage


### Data processing nodes

_meegpipe_ allows you to build processing pipelines by definining what you
want to do with your data in terms of _processing nodes_. There are
processing nodes for a variaty of tasks: importing from disk, filtering,
bad channel rejection, removing artifacts, feature extraction, etc. You can
also easily define your own nodes that will integrate seamlessly with
the _meegpipe_ framework.

For convenience, we bring package _meegpipe_ to the current name space:

````
import meegpipe.*;
````

Generate a [physioset][physioset] object from a MATLAB matrix using a
[physioset_import][physioset_import_node] node:

[physioset]: https://github.com/meegpipe/meegpipe/blob/master/%2Bphysioset/%40physioset/README.md
[physioset_import_node]: https://github.com/meegpipe/meegpipe/blob/master/%2Bmeegpipe/%2Bnode/%2Bphysioset_import/README.md

````matlab
myImporter = physioset.import.matrix('SamplingRate', 250);
n0 = node.physioset_import.new('Importer', myImporter);
% Run it! import the data!
data = run(n0, randn(15, 10000));
````

Use a [filter][filter-node] node to detrend the imported data using a 10th
 order polynomial:

[filter-node]: https://github.com/meegpipe/meegpipe/blob/master/%2Bmeegpipe/%2Bnode/%2Bfilter/README.md

````matlab
n1 = node.filter.new('Filter', filter.polyfit('Order', 10));
run(n1, data);
````

Use a [bad_channels][bad_channels-node] node to reject bad channels:

[bad_channels-node]: https://github.com/meegpipe/meegpipe/blob/master/%2Bmeegpipe/%2Bnode/%2Bbad_channels/README.md

````matlab
n2  = node.bad_channels.new;
run(n2, data);
````
Apply a band pass filter between 0.1 and 70 Hz:

````matlab
myFilter = @(sr) filter.bpfilt('Fp', [0.1 70]/(sr/2));
n3   = node.filter.new('Filter', myFilter);
run(n3, data);
````

Remove powerline noise using [Blind Source Separation (BSS)][bss], i.e.
using a [bss][bss-node] node:

[bss-node]: https://github.com/meegpipe/meegpipe/tree/master/%2Bmeegpipe/%2Bnode/%2Bbss/README.md
[bss]: http://en.wikipedia.org/wiki/Blind_signal_separation

````matlab
n4   = node.bss.pwl;
run(n4, data);
````

Reject ocular artifacts using BSS:

````matlab
n5   = node.bss.eog;
run(n5, data);
````

Export to EEGLAB format using a [physioset_export][physioset_export-node]
node:

[physioset_export-node]: https://github.com/meegpipe/meegpipe/tree/master/%2Bmeegpipe/%2Bnode/%2Bphysioset_export/README.md

````matlab
myExporter = physioset.export.eeglab;
n6 = node.physioset_export.new('Exporter', myExporter);
run(n6, data);
````

For more information and a list of available processing nodes, see the
[documentation][nodes-docs].

[wiki-ref]: http://en.wikipedia.org/wiki/Reference_(computer_science)
[nodes-docs]: http://github.com/meegpipe/meegpipe/blob/master/+meegpipe/+node/README.md


### Pipelines

A `pipeline` is just a concatenation of nodes. With the exception of
[physioset_import][node-physioset_import] nodes, all other node classes always
take a [physioset][physioset] as input. And with the exception of
[physioset_export][node-physioset_export] nodes, all other node classes produce a
`physioset` object as output.

The five processing steps that we performed above when illustrating how nodes
work could have been grouped into a pipeline:

[node-physioset_import]: https://github.com/meegpipe/meegpipe/blob/master/%2Bmeegpipe/%2Bnode/%2Bphysioset_import/%40physioset_import/physioset_import.m
[node-physioset_export]: https://github.com/meegpipe/meegpipe/blob/master/%2Bmeegpipe/%2Bnode/%2Bphysioset_export/%40physioset_export/physioset_export.m

````matlab
import meegpipe.*;
import physioset.import.*;

myPipe = node.pipeline.new(...
    'NodeList', {n0, n1, n2, n3, n4, n5, n6});

% Will produce an output file in EEGLAB format
run(myPipe, randn(15, 10000));

````

### Processing reports

Every processing node (or pipeline) generates a comprehensive HTML report
 for every data file that is processed. Namely, if you ran the pipeline
example above, you will find the corresponding HTML report under:


    [input_file_name].meegpipe/[pipe_name]_[blahblah]/index.htm


__NOTE:__ Neither Firefox nor Google Chrome are able to display local .svg
 files, when running under Windows 8. Whenever trying to do so, both
 browsers attempt to download the file and thus the file is not displayed.
Read the [document on known issues and limitations][issues] for ways to
 overcome this problem.

[issues]: https://github.com/meegpipe/meegpipe/blob/master/issues.md


__NOTE:__ The HTML reports will be generated only if you have installed all
the [recommended dependencies][recommended-dep] on your system.




## More information

See the practical [tutorials](http://github.com/meegpipe/meegpipe/tree/master/tutorials/README.md)
for some typical use cases of _meegpipe_. A high-level description of the API components
can be found in the [documentation][doc-main]. The documentation is still
work in progress.

[doc-main]: https://github.com/meegpipe/meegpipe/blob/master/%2Bmeegpipe/README.md


## License

For convenience, _meegpipe_ ships together with code from third-parties.
You can find a comprehensive list [here][attribution].

[attribution]: https://github.com/meegpipe/meegpipe/blob/master/attribution.md


Any code that is not part of any of the bundled third-party dependencies
(see [the list][attribution]), is released under the
[GNU General Public License version 3 or
later.](http://www.gnu.org/licenses/gpl.txt)
