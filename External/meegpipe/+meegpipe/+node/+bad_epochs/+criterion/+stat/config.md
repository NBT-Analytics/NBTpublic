`config` for criterion `stat`
===

This class is a helper class that provides consistency checks for the
configuration options accepted by the [stat][stat] bad epochs rejection
criterion. Please note that, apart from those options listed below, the 
`stat` criterion also admits all the configuration options accepted by 
its parent [rank criterion][rank].

[var]: ./README.md
[rank]: ../+rank/README.md


## Configuration options

### `ChannelStat`

__Class:__ `function_handle`

__Default:__ `@(x) max(abs(x))`

The data values of each channel within an epoch will be summarized into a
single scalar statistic using this `function_handle`. These channel
statistics will be subsequently aggregated into a single scalar epoch
 statistic (see below).

The default `ChannelStat` characterized each data channel by its maximum 
absolute value.



### `EpochStat`

__Class__: `function_handle`

__Default__: `@(x) max(x)`

The channel statistics obtained using `ChannelStat` will be aggregated 
into a single scalar statistic using `EpochStat`. For instance, the 
default value of `EpochStat` characterizes an epoch using the maximum value
of all channel statistics. 