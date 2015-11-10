eeglab
========

Conversion to an EEGLAB structure

## Usage

````matlab
EEG = eeglab(pObj)
EEG = eeglab(eegsetObj, 'key', value, ...)
````

where

`pObj` is a `physioset` object

`EEG` is the exported EEGLAB data structure


## Accepted (optional) key/value options:

### BadDataPolicy

__Default:__ `'reject'`
__Class:__    `char`

Determines what is to be done with the bad data when exporting to EEGLAB
format. See the documentation of 
[physioset.deal_with_bad_data][deal_with_bad_data] for information
regarding valid bad data policies.

[deal_with_bad_data]: ../deal_with_bad_data.md


## Notes:

* This method requires the EEGLAB toolbox:
  http://sccn.ucsd.edu/eeglab/

* Once a physioset has been exported to EEGLAB format, you can easily
  load it into EEGLAB, by doing the following:

````matlab
  eeglab; % Start EEGLAB
  [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
````

  Where `EEG` is the result of converting a physioset to EEGLAB
  format.

* For epoched datasets, any trial that contains one or more bad samples
  will be rejected. This might be too harsh but allows a simplified
  implementation.


## Examples

__Export only the EEG channels__

````matlab
data = pset.load('myfile.pseth');
selector =  pset.selector.sensor_class('Class', 'EEG');
select(selector, data);
eeglabStr = eeglab(data);
eeglab; % Start EEGLAB
[ALLEEG EEG] = eeg_store(ALLEEG, eeglabStr, CURRENTSET);
eeglab redraw;
````

## More information

[physioset.physioset.fieldtrip][ftrip-doc]
[EEGLAB toolbox][eeglab]

[ftrip-doc]: ./fieldtrip.md

[eeglab]: http://sccn.ucsd.edu/eeglab