`config` for node `spectra`
===


This class is a helper class that implements consistency checks necessary for
building a valid [spectra][spectra] node.

[spectra]: ./README.md


## Usage synopsis

Create a spectra node that will plot the average spectra across channels
with labels `'EEG 20'`, `'EEG 21'`, ..., `EEG 29` using a Welch spectral
estimator:

````matlab
import meegpipe.node.*;
myConfig = spectra.config(...
    'Channels',  'EEG 2.$', ...
    'Estimator',spectrum.welch);

myNode = spectra.new(myConfig);
````

The following syntax is completely equivalent and is preferable for being
more concise:

````matlab
import meegpipe.node.*;
myNode = spectra.new(...
    'Channels',  'EEG 2.$', ...
    'Estimator',spectrum.welch);
````

## Configuration properties

The following construction options are accepted by the constructor of
this config class, and thus by the constructor of the `spectra` node class:

### `ROI`

__Class__: `mjava.hash` or `[]`

__Default__: `meegpipe.node.spectra.eeg_bands`

A hash containing power Ratios-of-Interest specifications. There are two
ways of specifying a ROI. The first specifies the start and end of the
_target_ band using a vector:

````matlab
boi = mjava.hash;
boi('alpha') = [8 13];
boi('gamma') = [30 100];
````
The latter implicitely assumes a _reference_ band spanning the range 
`[0 fmax]` where `fmax` is the maximum measurable frequency, i.e. the 
Nyquist rate.

The second possible specification is as follows:

````matlab
boi = mjava.hash;
boi('alphaVSgamma') = {[8 13], [30 100]};
````

Indicating that the node should compute the power ratio between the alpha
band (`[8 13]`) and the gamma band (`[30 100]`).


### `Channels`

__Class__: `cell array` or a `string` (a regular expression)

__Default__: '.+'

A regular expression (or a list of regular expressions) to be matched
against the labels of the data channels. A spectra plot will be generated
for each such regular expression.

### `Duration`

__Class__: `numeric scalar`

__Default__: `[]`

If provided, the `Duration` property of the relevant events will be ignored
and replaced by the value of the node's `Duration` property. This property
can be used to ensure that all analysis epochs have equal length.


### `EventSelector`

__Class__: `physioset.event.selector`

__Default__: `{physioset.event.class_selector('Type', 'spectra')}`

The provided `selector` will be used to select relevant epochs from the
input physioset. The node will compute the average spectra across epochs.
All epochs must have equal lengths or an error will be generated.



### `Estimator`

__Class__: `spectrum.*` or `function_handle`


__Default__: ` @(fs)spectrum2.percentile('Estimator', spectrum.welch('Hamming', 2*fs));`


The spectral estimator. If a `function_handle` is provided, the actual
estimator will be obtained during run-time by evaluating the value of
`Estimator` with the sampling rate of the considered physioset. The default
estimator uses this technique to ensure that the segment length of the
Welch estimator is equal to 2 seconds, regardless of the sampling rate of
the input data.

Note that if the spectra is computed across a group of epochs then the
corresponding estimator must accept multiple time-series for method psd. 
In practice this means that if you decide to compute average spectra
across several epochs (i.e. using property `EventSelector`) then you must
use a `spectrum2.percentile` estimator.


### `Normalized`

__Class__: `logical`

__Default__: `true`

If set to true, the spectral features (power ratios) will be normalized so 
that they are not affected by the length of the band of interest. 
Normalization leads to easier to interpret features. 


### `Offset`

__Class__: `numeric scalar`

__Default__: `[]`

If provided, the `Offset` property of the relevant events will be ignored
and replaced the provided node `Offset` will be used instead.


### `Plotter`

__Class__: `plotter.plotter` or `function_handle`
 
__Default__: `@(sr) plotter.psd.psd('FrequencyRange', [0 min(60, sr/4)])`

The plotter to use for generating the PSD figures that appear in the data
processing report. If this property is set to a `function_handle` the 
actual plotter object will be obtained by evaluating `Plotter` at the 
sampling rate of the node input. 

The example below constructs a `spectra` node that will plot PSDs in 
a logarithmic scale, and will plot only power between 1 Hz and 40 Hz:

````matlab
myPlotter = plotter.psd.psd('FrequencyRange', [1 40], 'LogData', true);
import meegpipe.node.*;
myNode = spectra.new('Plotter', myPlotter);
````
