function out = compute_erp_features(x, varargin)
% COMPUTE_ERP_FEATURES - Extract latency/peak features from an ERP waveform
%
% out = erp_features(x, 'key', val, ...)
% out = erp_features(x);
%
% Where
%
% X is a 1xN vector with the ERP signal
%
% OUT is a struct with fields:
%
%       latency       -> The peak latency
%       amplitude     -> The peak amplitude
%       avg_amplitude -> The average ERP amplitude. See key opt.AvgWindow.
%
%
% ## Accepted key/value pairs:
%
%       LatRange : A 1x2 vector specifying the range of latencies (in ms) 
%           where the peak should be found (def: [500 700])
%
%       AvgWindow : Size of the window (in ms) around the peak that will be
%           used to calculate the average peak amplitude (def: 100)
%
%       SamplingRate : Sampling rate in Hz (def: 256)
%
%       MinMax : If set to 'min' the peak will be a local minimum.
%           Otherwise the peak will be a local maximum. (def: 'max')
%
%       PreStimulus : Pre-stimulus interval, in ms (def: 200)
%
% See also: misc.peakdet

import misc.process_arguments;
import misc.peakdet;

% Default values of the optional input arguments
opt.LatRange        = [400 500];
opt.AvgWindow       = 100;
opt.SamplingRate    = 256;
opt.MinMax          = 'max';
opt.PreStimulus     = 200;
opt.Delta           = 2;
opt.MinDelta        = 0.1;

[~, opt] = process_arguments(opt, varargin);

if strcmpi(opt.MinMax, 'min'),
    x = -x;
end

sr = opt.SamplingRate;

t = round(...
    linspace(-opt.PreStimulus, 1e3*numel(x)/sr-opt.PreStimulus, numel(x)));

x_range = x(t >= opt.LatRange(1) & t < opt.LatRange(2));
t_range = t(t >= opt.LatRange(1) & t < opt.LatRange(2));

if isempty(t_range),
    error('The peak latency range does not overlap with the epoch range');
end

maxtab = [];
while (isempty(maxtab)) && opt.Delta > opt.MinDelta,
    maxtab = peakdet(x_range, opt.Delta);
    opt.Delta = 0.9*opt.Delta;
end

if isempty(maxtab),
    out.latency = NaN;
    out.amplitude = NaN;
    out.avg_amplitude = NaN;
    return;
end

[~, idx] = max(maxtab(:,2));
latency = t_range(maxtab(idx, 1));
latency_sample = find(t>=latency,1, 'first' );

if strcmpi(opt.MinMax, 'min'),
    x = -x;
end

out.latency       = latency;
out.amplitude     = x(latency_sample);
out.avg_amplitude = ...
    mean(x( t > latency-opt.AvgWindow/2 & t < latency+opt.AvgWindow/2));