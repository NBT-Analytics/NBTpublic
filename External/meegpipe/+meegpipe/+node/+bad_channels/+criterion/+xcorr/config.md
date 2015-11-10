`config` for criterion `xcorr`
===


This class is a helper class that provides consistency checks for the
configuration options accepted by the [xcorr][xcorr] bad channels rejection
criterion. Please note that, apart from those options listed below, the 
`var` criterion also admits all the configuration options accepted by 
its parent [rank criterion][rank].

[xcorr]: ./README.md
[rank]: ../+rank/README.md


## Configuration options

### `NN`

__Class:__ `numeric scalar`

__Default:__ `10`

Number of nearest channels against which the curren channel will be compared.

