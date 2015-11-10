function fObj = eog(varargin)
% EOG - LASIP filter for EOG-like spatial components
%
% fObj = filter.lasip.eog();
% fObj = filter.lasip.eog('key', value, ...)
%
% Any provided key/value pair will be passed directly to the constructor of
% the LASIP filter.
%
% See also: filter

% We use a decimation factor of just 2, which should work OK when data is
% sampled at about 250 Hz. You may want to increase Decimation for higher
% sampling rates.
fObj = filter.lasip('Gamma', 3.5:0.25:5.5, 'Decimation',2, varargin{:});


end