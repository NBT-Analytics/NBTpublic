`psd_ratio` feature
========

Feature `psd_ratio` computes the power ratio between a target band of 
interest and a reference band.


## Usage synopsis

```matlab
% Create a dummy physioset
data = import(physioset.import.matrix, randn(4, 10000));
  
% Ensure that the second channel has most power within 3Hz and 10Hz
myFilter = filter.bpfilt('fp', [3 10]/(data.SamplingRate/2));
data(2,:) = filter(myFilter, data(2,:));

% Use psd_ratio features to identify the filtered channel
myFeat = spt.feature.psd_ratio('TargetBand', [3 10], 'RefBand', [20 30]);
featVal = extract_feature(myFeat, [], data);
[~, I] = max(featVal);
assert(I == 2);
```


## Criterion properties

### `TargetBand`

__Class__: `1x2 numeric array`

__Default__: `[]`

The band of interest, i.e. the band where you expect the signal of interest
to have a higher SNR.


### `RefBand`

__Class__: `1x2 numeric array`

__Default__: `[]`

The reference band, i.e. the band where you expect the signal of interest 
to have lowest SNR.


### `Estimator`

__Class__: `function_handle`

__Default__: `@(x, sr) pwelch(x, min(ceil(numel(x)/5),sr*3), [], [], sr)`

The spectral estimator used to compute the power in the band of interest 
and in the reference band. `Estimator` is defined as function handle that 
takes two arguments: a time series, and the corresponding sampling rate. 
The output produced by `Estimator` is a PSD object with the corresponding
power spectral density.

__NOTE:__ In general, it is not a good idea to change the default 
`Estimator` without a good reason. If you do change the default spectral 
estimator then it is recommended to change accordingly the estimator used
for reporting PSDs of estimated spatial components. Otherwise, the PSDs
shown in the HTML reports may not match the PSDs that were used to extract 
the `psd_ratio` features. This can make difficult the selection of feature 
thresholds for automatic selection of spatial components. 

### `TargetBandStat`

__Class__: `function_handle`

__Default__: `@(power) prctile(power, 75);`

The statistic used to summarize power in the band of interest. The default 
value of `TargetBandStat` uses the 75% percentile of the power values across all
frequency bins within the band of interest.


### `RefBandStat`

__Class__: `function_handle`

__Default__: `@(power) prctile(power, 25)`

The statistic used to summarize power in the reference band.
