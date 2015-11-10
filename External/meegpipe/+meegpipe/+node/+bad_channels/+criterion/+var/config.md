`config` for criterion `var`
===

This class is a helper class that provides consistency checks for the
configuration options accepted by the [var][var] bad channels rejection
criterion. Please note that, apart from those options listed below, the 
`var` criterion also admits all the configuration options accepted by 
its parent [rank criterion][rank].

[var]: ./README.md
[rank]: ../+rank/README.md

## Configuration options

### `NN`

__Class:__ `numeric scalar`

__Default:__ `10`

Number of nearest channels to use for the computation of the baseline variance.
Use `NN=inf` if  you want to reject channels that have abnormally low or high
variance with respect to all other channels. Use `NN=5` to reject channels whose
variance is much larger or much lower than the average variance in the 5 nearest
channels.


### `Filter`

__Class__: `filter.dfilt` or `[]`

__Default__: `[]`, i.e. no filtering

The data fill be pre-filtered using this filter before computing the data
variances.

### `Normalize`

__Class__: `logical`

__Default__: `true`

If set to true, the output of the filter will be scaled according to the
unfiltered variance of each channel. Note that this option is ignored if 
property `Filter` is set to `[]` (which is the default setting).
