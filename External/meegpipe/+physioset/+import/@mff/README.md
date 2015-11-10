mff data importer
================

The `mff` data importer can be used to create a [physioset][physioset] 
using data contained in [EGI][egi]'s `.mff` data format. Note that this 
importer is generally preferable over the [fileio][fileio] importer, which
is also able to import `.mff` files. The latter has several limitations and
does not support multiplexed data channels. 

[egi]: http://www.egi.com/
[physioset]: ../../%40physioset
[fileio]: ../%40fileio

## Basic usage

````matlab
myData = import(physioset.import.mff, 'myfile.mff');
````


## Examples

### Import multiplexed temperature data

The `.mff` importer supports multiplexed physiological data. At this point
only temperature data produced by [Braintronics][braintronics]'s 
TEMPMUX-1012 is supported. The TEMPMUX-1012 multiplexes 16 temperature
channels over one DC channel, e.g. over one channel of the [Polygraph 
Input Box (PIB)][pib] produced by [EGI][egi]. An important pre-requisite is
that channels that contain multiplexed data must have a standard label name 
that follows the convention:

````
Mux [manufacturer]_[model]_[submodel]
````

This means that channels that contain data multiplexed with 
Braintronics TEMPMUX-1012 must be labeled as `Mux braintronics_tempmux_1012`.
Note also that this channel label complies with the 
[EDF+ recommendations][edfplus-recs]. If you did not follow this naming
convention when you recorded your data you can edit the channel labels
a-posteriori by editing the appropriate `.xml` file within the `.mff`
package/directory. Typically, the relevant file will be named `pnsSet.xml`.

[edfplus-recs]: http://www.edfplus.info/specs/edfplus.html#additionalspecs

The data import should be straightforward, as long as the multiplexed data
channels have the correct labels:

````matlab
% Download a sample .mff file with multiplexed temp data
DATA_URL = ['http://kasku.org/data/meegpipe/' ...
    'test_mux.mff.tgz'];
untar(DATA_URL, pwd);

% Import the data file
data = import(physioset.import.mff, 'test_mux.mff');

% Display info about the physioset object
disp(data)
````

The last command above should display something like:

````matlab
>> disp(data)
handle
Package: pset


                Name : test_mux
               Event : []
             Sensors : 257 sensors.eeg; 6 sensors.physiology; 12 sensors.physiology; 
         SampingRate : 1000 Hz
             Samples : 94697 ( 94.7 seconds), 0 bad samples (0.0%)
            Channels : 275, 0 bad channels (0.0%)
           StartTime : 04-Oct-0023 11:25:25
        Equalization : no

Meta properties:

````

As you can see, the physioset contains three sensor groups. The first 
group contains 257 EEG sensors, the second group contains 6 physiological
sensors (coming from EGI's PIB box), and the third group is the result of
unmultimplexing the multiplexed PIB channel that contains data coming from
12 different temperature sensors. Note that the original temperature data
was sampled at 2 Hz but it has been appropriately upsampled (using 
linear interpolation) to 1000 Hz. 

[braintronics]: http://www.braintronics.nl
[pib]: http://www.unl.edu/dbrainlab/*files/intranet/ERP%20data%20collection/PIB_instructions_plac_8404162-51_20100427.pdf


You can select the unmultiplexed data channels using:

````matlab
% Create a data selector object
mySel = pset.selector.sensor_class('Type', 'Temp');
select(mySel, data);

% So you temp data matrix is:
myTempData = data(:,:);
plot(myTempData');
````
