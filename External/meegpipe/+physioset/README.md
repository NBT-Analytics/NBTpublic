`physioset` API documentation
================

The MATLAB package [physioset][physioset-pkg] contains various data 
structures and supporting functions to handle high-dimensional 
physiological datasets. The main component of the `physioset` package API 
is the [physioset class][physioset-class]. Below you can find a list of 
all API components. The `@` symbol is used to denote classes, the `+` 
symbol is used to identify MATLAB packages. 

API component                  | What is it for? 
--------------                 | -------------------- 
[@physioset][physioset-class]  | Main data structure for high-dimensional physiological datasets
[+event][event-pkg]            | Handling events within physiosets
[+import][import-pkg]          | Importing data from disk files
[+plotter][plotter-pkg]        | Plotting physiological datasets

[physioset-pkg]: ./
[physioset-class]: ./%40physioset
[event-pkg]: ./%2Bevent
[import-pkg]: ./%2Bimport
[plotter-pkg]: ./%2Bplotter

Below you can find some usage examples of the API provided by the 
`physioset` package. All the examples assume that [meegpipe][meegpipe] is
in your MATLAB path and that you have run the following two lines when you
started your MATLAB session:

````matlab
clear all;
meegpipe.initialize;
````

[meegpipe]: https://github.com/germangh/meegpipe


## Create physioset from a MATLAB matrix

Physiosets are almost always created using a suitable _importer_, 
implemented by one of the classes contained in the [+import][import-pkg] 
package. To import data from a MATLAB matrix we need to use the 
[matrix][matrix-class] importer:

[matrix-class]: ./%2Bimport/%40matrix

````matlab
% Create a random data matrix (10 data channels, 1000 samples)
X = randn(10, 1000);

% Create matrix importer object
myImporter = physioset.import.matrix;

% Use myImporter to import data matrix X
myData = import(myImporter, X);

% Display some information on the generated physioset
% This is equivalent to omitting the semicolon in the line above
disp(myData);

````

The last command above will generate an output similar to this:

````matlab

handle
Package: pset


                Name : 20130422T104001_ee223
               Event : []
             Sensors : 10 sensors.dummy; 
         SampingRate : 250 Hz
             Samples : 1000 (  4.0 seconds), 0 bad samples (0.0%)
            Channels : 10, 0 bad channels (0.0%)
           StartTime : 22-Apr-2013 10:40:01
        Equalization : no

Meta properties:

````

Note that method `import()` of the `matrix` importer made quite a few 
assumptions such as the sampling rate of your data (250 Hz) and the type
of sensors that were used to acquire the data (some `dummy` sensors, 
meaning that the sensor class is unknown, or not applicable). You can 
override such assumptions by building a custom `matrix` importer. For 
instance, to build a `matrix` importer that will import EEG data sampled 
at 1000 Hz:

````matlab

% Create a set of 10 EEG sensors
% For more information see the documentation of the sensors module
% at https://github.com/germangh/matlab_sensors
% The sensor labels must follow the EDF+ standard naming conventions,
% described at: http://www.edfplus.info/specs/edfplus.html#additionalspecs
myLabels = arrayfun(@(x) ['EEG ' num2str(x)], 1:10, 'UniformOutput', false);
mySensors = sensors.eeg('Label', myLabels);

% Create the importer. Notice that we ommit the semicolon so that method 
% disp() is implicitely called on myImporter. This is useful to ensure 
% that the properties of myImporter were set correctly.
myImporter = physioset.import.matrix( ...
    'SamplingRate', 1000, ...
    'Sensors',      mySensors)

% And import the data matrix
X = randn(10, 1000);
myData = import(myImporter, X);

````

For more information regarding data importers see the documentation of
the [+import][import-pkg] package.

## Plot a physioset

````matlab

% Create a physioset object containing random data
X = randn(10, 5000);
myData = import(physioset.import.matrix, X);

% Plot it
plot(myData);

````

## Sampling instants

`physioset` objects keep track of the sampling instants associated to each 
of the data samples contained in the physioset. You can retrieve the 
relative timing of a set of samples using:

````matlab
% Retrieve the relative timing of samples 10:10:100
time = get_sampling_time(myData, 10:10:100);
````

The times above are relative to the physioset _time origin_, which can 
be retrieved using:

````matlab
timeOrig = get_time_origin(myData);
````

You can also retrieve absolute sampling timings using:

````matlab
[~, absTimes] = get_sampling_time(myData, 10:10:100);
````

The following assertion illustrates how relative timings can be converted 
to absolute ones:

````matlab
[time, absTime] = get_sampling_time(myData, 10:10:100);
timeOrig = get_time_origin(myData);

msPerDay = 24*60*60*1000;
absTime2 = timeOrig + round(time*1000)/msPerDay;

assert(all(absTime == absTime2));
````

## Data selections

Sometimes you want to plot or process just a sub-set of the data contained
in a `physioset`. There are two ways you can achieve this. The first is 
to simply dereference the data that you want to process, i.e. create a 
MATLAB matrix out of a subset of the `physioset` data:

````matlab
% Create a physioset object containing random data
X = randn(10, 5000);
myData = import(physioset.import.matrix, X);

% Select only channels 1 to 5
myDataMatrix = myData(1:5,:);
assert(strcmp(class(myDataMatrix), 'double'));

% Plot the MATLAB matrix myDataMatrix using MATLAB built-in plot()
plot(myDataMatrix');

````

There are two major disadvantages to the approach above:

* By dereferencing we are actually creating a copy of the data contained in 
the 5 first data channels and we are loading such copy in MATLAB's 
workspace. This is OK for a small physioset like the one in the example, 
but may be impossible to do for very large physiosets (due to memory 
limitations).

* Dereferencing produces a built-in MATLAB matrix of double precision. This
means that any meta-data that was contained in the physioset (e.g. the 
sensor classes, sampling rate, etc.) are lost. Thus, only MATLAB built-in 
methos that apply to double matrices can be used with `myDataMatrix`.

The second alternative is typically preferable and consists in _selecting_ 
the sub-set of data that we want to operate with:

````matlab
% Create a physioset object containing random data
X = randn(10, 5000);
myData = import(physioset.import.matrix, X);
assert(all(size(myData) == [10, 5000]));

% Select only the first 5 data channels
select(myData, 1:5);
assert(all(size(myData) == [5, 5000]));

% Plot the first data channels
plot(myData);

% Undo the data selection
restore_selection(myData);
assert(all(size(myData) == [10, 5000]));

````

## Working with events

````matlab
% Create a physioset object containing random data
X = randn(10, 5000);
myData = import(physioset.import.matrix, X);

% Create 5 events at samples 1000, 2000, ..., 5000
% of type 'my_event'
myEvArray = physioset.event.event(1000:1000:5000, 'Type', 'my_event');
add_event(myData, myEvArray);

% Plot the data. Can you see the event markers?
plot(myData);

% Retrieve the events stored in the physioset object
myEvArray = get_event(myData);

% Delete first 3 events
delete_event(myData, 1:3);

````

You can also add and remove events from a physioset using a rudimentary 
GUI (which relies on EEGLAB's `eegplot` functionality). To add events 
to `myData` using the GUI just call method `add_event` without any 
argument:

````matlab
add_event(myData);
````

Similarly, you can remove events using the GUI:

````matlab
delete_event(data);
````

The latter command will open a GUI where the user will be able to perform 
multiple time window selections. Any event whose onset falls within the 
selected windows will be removed from `myData`. 

For more information regarding physioset events see the documentation of
the [+event][event-pkg] package.

## Create a physioset from an EDF+ file

````matlab
% Download a sample EDF+ file
DATA_URL = ['http://kasku.org/data/meegpipe/' ...
    'pupw_0005_physiology_afternoon-sitting_day1.edf']

urlwrite(DATA_URL, 'sample.edf');

% Create an EDF+ data importer
myImporter = physioset.import.edfplus;

% Import data from the disk file
data = import(myImporter, 'sample.edf');

````

There are several other data importers available in package 
[import][import-pkg]. One of the most versatile data importers is the 
[fileio][fileio-importer] importer, which is just a wrapper around 
[Fieldtrip][fieldtrip]'s fileio module. Thus, the `fileio` importer should
be able to import data from any format supported by Fieldtrip. 

[fileio-importer]: ./%2Bimport/%40fileio

For more information regarding data importers for other file data formats
see the documentation of the [+import][import-pkg] package.


## Export to other data formats

A `physioset` object can be converted to a [Fieldtrip][fieldtrip] or 
[EEGLAB][eeglab] data structure:

[fieldtrip]: http://fieldtrip.fcdonders.nl/
[eeglab]: http://sccn.ucsd.edu/eeglab/

````matlab
% Create a physioset object containing "simulated" EEG data
myLabels = arrayfun(@(x) ['EEG ' num2str(x)], 1:10, 'UniformOutput', false);
mySensors = sensors.eeg('Label', myLabels);
myImporter = physioset.import.matrix( ...
    'SamplingRate', 1000, ...
    'Sensors',      mySensors)
myData = import(myImporter, randn(10, 5000));

% Add some events
myEvents = physioset.event.event(1000:1000:5000, 'Type', 'mytype');
add_event(myData, myEvents);

% Convert to Fieldtrip structure
myFtripStr = fieldtrip(myData);

% Convert to EEGLAB structure
myEEGLABStr = eeglab(myData);


````

