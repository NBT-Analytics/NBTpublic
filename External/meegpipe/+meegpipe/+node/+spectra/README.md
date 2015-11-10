`spectra` - Spectral analysis
===

The `spectra` node computes spectra of individual channels or of channel
aggregates.

## Usage synopsis:

````matlab
import meegpipe.*;
obj = node.spectra.new('key', value, ...);
run(obj, data);
````

where `data` is a [physioset][physioset] object.

[physioset]: https://github.com/germangh/matlab_physioset/blob/master/%2Bphysioset/%40physioset/README.md


## Construction arguments

The `spectra` node admits all the key/value pairs admitted by the
[abstract_node][abstract-node] class. For configuration options specific to this
node class see the documentation of the helper [config][config] class.

[abstract-node]: ../@abstract_node/README.md
[config]: ./config.md


## Methods

See the documentation of the [node API documentation][node].

[node]: ../


## Use case

The code snippets below assume that _meegpipe_ has initialized using:

````matlab
clear all;
meegpipe.initialize;
````

This use case aims to compute the following spectral features:

* The (normalized) power in the alpha band (8 to 13 Hz)
* The ratio of normalized power in the alpha band versus normalized power in
  the gamma band (30 to 100 Hz).

We want to compute those spectral features from a set of EEG files obtained in
two experimental conditions:

* Condition `in-rs-eo-ec`: Resting state, changing from eyes open to eyes
  closed, lying on the MR scanner board.
* Condition `rs-eo-ec-supine`: Same as `in-rs-eo-ec` but outside the
  scanner room, lying on a bed.

A group of 4 subjects undertook this experiment. This means that we
want to process a total of 8 data files (4 per condition).

### Create the analysis pipeline

First we need to define our power Ratios of Interest (ROIs):

````matlab
myROIs = mjava.hash;
myROIs('alpha') = [8 14];
myROIs('avsg') = {[8 14],[30,100]};
````
Note that the `alpha` ROI does not especify the reference band to be
used as the denominator in the power ratio. In such cases, a `[fmin fmax]`
reference band will be assumed, with `fmin` and `fmax` the minimum and
maximum measurable frequencies. In general, it is best to explicitly specify the
reference band of interest, e.g the following definition of the `alpha` band
explicitely indicates that alpha power should be relative to power within the
band from 0 Hz to 100 Hz:

````matlab
myROIs = mjava.hash;
myROIs('alpha') = {[8 14], [0 100]};
````
Frequencies above 100 Hz are rarely of any interest for EEG researchers and thus
it makes sense to ignore those frequencies when computing power spectral ratios.
Those ROI's named as standard [EEG rhythms][eegbands] will be also plotted in
the generated report. In our case, this means that the value of the `alpha`
power ratio will be plotted in the node report.


[eegbands]: http://en.wikipedia.org/wiki/Electroencephalography

We want to compute the spectral ratios of interest for two sets of channels:

* For channel `EEG 101`

* For channels `EEG 200` to `EEG 219`. In this case we are interested in the
  median value of the spectral ratios across all channels within this set.

We can build a suitable `spectra` node as follows:

````matlab
import meegpipe.node.*;
chans = {'EEG 101', 'EEG 2(0|1)\d'};
myNode = spectra.new('Normalized', true, 'ROI', myROIs, 'Channels', chans);
````

The constructor of `spectra` nodes accepts several other
[configuration options][config].

[config]: ./config.md

Our pipeline will also include some basic pre-processing steps and
is defined as shown below:

````matlab
import meegpipe.node.*;
filterNode = tfilter.new('Filter', filter.hpfilt('fc', 1/500));
myPipe = pipeline.new('NodeList', ...
    { ...
    physioset_import.new('Importer', physioset.import.mff), ...
    detrend.new, ...     % Remove very low frequencies trends
    filterNode, ...      % High-pass filtering
    myNode ...           % The spectral analysis node
    }, 'Name', 'spectra-use-case');
````



### Linking to the relevant data files

Assuming that you are working at `somerengrid` (our lab's private grid),
you can produce symbolic links to the relevant data files using the
following command (from MATLAB):

````matlab
filesIn  = somsds.link2rec('bcgg', 'modality', 'eeg', ...
                'condition', 'in-rs-eo-ec', 'file_ext', '.mff');
filesOut = somsds.link2rec('bcgg', 'modality', 'eeg', ...
                'condition', 'rs-eo-ec-supine', 'file_ext', '.mff');
````

where `filesIn` and `filesOut` are cell arrays with the full path names of
the generated links for the two conditions. The first input argument to
`somsds.link2rec` is just the code name of the experiment, which in this
case happens to be `bcgg`. Apart from specifying the modality and condition of
the relevant data files, we also use argument `file_ext` to select only `.mff`
files and ignore files in any other data format (e.g. in `.edf` format).


### File-level analysis

We are now ready to run the pipeline that we defined above on every data
file:

````matlab
run(myPipe, filesIn{:}, filesOut{:});
````

### Aggregating file-level results

Once the file-level processing/analysis jobs are completed, we aggregate
the spectral features that were obtained for individual files into a single
table, more suitable for subsequent statistical modeling. The
aggregation requires the user to provide a [regular expression][regex] that
matches individual features files. In our case, the features were generated
by the a node called `spectra`, which stores the features in a text file
named `features.txt`. Thus, the aggregation works as follows:

[regex]: http://en.wikipedia.org/wiki/Regular_expression

````matlab
% You could devise many other regular expressions that would do
% the same job as this one
regex = 'spectra-use-case.+(/|\\)node-4-spectra(/|\\)features.txt$';
fNameIn  = meegpipe.aggregate(filesIn, regex);
fNameOut = meegpipe.aagregate(filesOut, regex);
````
Function [meegpipe.aggregate][aggregate] allows the user to provide a regular
expression that translates file names into a series of tokens. For instance, to
automatically extract the recording, modality, subject, and condition IDs from
the file names:

````matlab
regex = 'spectra-use-case.+(/|\\)node-4-spectra(/|\\)features.txt$';
fNameTrans = '(?<recid>.+?)_(?<subjid>.+?)_(?<modid>.+?)_(?<condid>[^\._]+)';
fNameIn  = meegpipe.aggregate(filesIn, regex, '', fNameTrans);
fNameOut = meegpipe.aagregate(filesOut, regex, '', fNameTrans);
`````

[aggregate]: ../../aggregate.md

