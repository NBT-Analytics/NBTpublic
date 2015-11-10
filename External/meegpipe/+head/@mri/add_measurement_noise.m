function obj = add_measurement_noise(obj, sigma)
% ADD_MEASUREMENT_NOISE - Adds measurement noise at the EEG sensors
%
% obj = add_measurement_noise(obj, sigma)
%
% Where
%
% OBJ is a head.mri object
%
% SIGMA is the standard deviation of the random Gaussian noise that will
% be added to the sensors
%
%
% See also: head.mri

% Description: Adds measurement noise
% Documentation: class_head_mri.txt

if nargin < 2 || isempty(sigma), sigma = 1; end


if obj.NbSensors < 1,
    error('This head model does not contain any EEG sensors!');
end


obj.MeasNoise = sigma*randn(obj.NbSensors, 1);




end