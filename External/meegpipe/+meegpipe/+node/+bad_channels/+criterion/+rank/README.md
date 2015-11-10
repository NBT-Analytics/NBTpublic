`rank` criterion class
===

The `rank` criterion for bad channels rejection is an abstract criterion
designed for inheritance. That means that you cannot create instances of
this criterion class, but you may use it as a scheleton for defining your
own custom criteria.

## Configuration options

All criteria classes that inherit from the `rank` criterion accept the 
following configuration options:


### `MinCard`

__Class:__ `numeric` scalar or `function_handle`

__Default:__ `0`

The minimum number of channels that will be rejected. If set to a 
`function_handle` the minimum number of channels that will be rejected 
will be obtained by evaluating `MinCard` on the number of channels of the
input dataset. That is, to ensure that at least 10% of channels are 
rejected you could set `MinCard` to `@(dim) ceil(0.1*dim)`.


### `MaxCard`

__Class:__ `numeric` scalar or `function_handle`

__Default:__ `@(dim) ceil(0.2*dim)`


The maximum number of channels that will be rejected. 

### `Min`

__Class:__ `numeric` scalar or `function_handle`

__Default:__ `@(x) median(x)-10*mad(x)`

The lower rank value threshold below which a channel will be rejected. If 
`Min` is set to a `function_handle`, then the actual lower threshold will
be obtained by evaluating `Min` on the array of rank values for all 
channels. That is, to ensure that those channels whose rank value is 10 
or more median absolute deviations below the median you should set `Min` 
to `@(rankVal) median(rankVal)-10*mad(rankVal)`.


### `Max`

__Class:__ `numeric` scalar or `function_handle`

__Default:__ `@(x) median(x)+10*mad(x)`

The upper rank value threshold above which a channel will be rejected.