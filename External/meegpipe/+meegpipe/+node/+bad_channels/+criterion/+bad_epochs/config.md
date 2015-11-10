`config` for criterion `bad_epochs`
===


This class is a helper class that provides consistency checks for the
configuration options accepted by the [bad_epochs][bad_epochs] criterion 
for bad channels rejection.

[bad_epochs]: ./README.md


## Configuration options


### `BadEpochsCriterion`

__Class:__ `meegpipe.node.bad_epochs.criterion.criterion`

__Default:__ `[]`, i.e. do nothing

The rejection criterion for bad epochs. This criterion will be used to 
determine how many epochs would be rejected if a given channel would not be
rejected. Channels that lead to a number of rejected epochs beyond the 
threshold `Max` will be rejected.

### `EventSelector`

__Class:__ `physioset.event.selector`

__Default:__ `[]`, i.e. do not select any event


### `Max` 

__Class:__ `numeric` or `function_handle`

__Default:__ `0.75`

The upper threshold for the number of bad epochs that should be rejected. 
Any channel whose presence in the data would lead to epoch rejection ration 
numbers above this threshold will be rejected. You can specify the `Max` 
threshold in three possible ways:

* As a percentage. Whenever `Max` is set to a numeric value below 1, it 
  will be interpreted as a percentage of the total number of epochs.

* As an absolute number of rejected epochs. That is, setting `Max` to `5` 
  will reject any channel that leads to more than 5 epochs being rejected.

* As a `function_handle` that produces the absolute number of epochs that 
can be rejected as a function of (1) the total number of epochs, and (2) 
the number of rejected epochs for a given channel.
