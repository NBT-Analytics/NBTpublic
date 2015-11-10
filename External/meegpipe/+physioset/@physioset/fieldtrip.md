fieldtrip - Conversion to an Fieldtrip structure
=======

## Usage

````matlab
ftripStr = fieldtrip(pObj)
ftripStr = fieldtrip(eegsetObj, 'key', value, ...)
````

where

`pObj` is a `physioset` object

`ftripStr` is the exported Fieldtrip data structure


## Accepted (optional) key/value options:

### BadDataPolicy

__Default:__ `'reject'`
__Class:__    `char`

Determines what is to be done with the bad data when exporting to
Fieldtrip format. See the documentation of
[physioset.deal_with_bad_data][deal_with_bad_data] for information
regarding valid bad data policies.

[deal_wit_bad_data]: ../deal_with_bad_data.md


## Notes:

* For epoched datasets, any trial that contains one or more bad samples
  will be rejected. This might be too harsh but allows a simplified
  implementation.


## Examples:

### Export only the EEG channels

````matlab
data = pset.load('myfile.pseth');
selector =  pset.selector.sensor_class('Class', 'EEG');
select(selector, data);
ftripStr = fieldtrip(data);
````

## More information

[physioset.physioset.eeglab][eeglab-doc]
[Fieldtrip toolbox][ftrip]

[eeglab-doc]: ./eeglab.md
[ftrip]: http://fieldtrip.fcdonders.nl
