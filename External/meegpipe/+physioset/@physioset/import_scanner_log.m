function y = import_scanner_log(eegset_obj, logfile, varargin)
% import.SCANNER_LOG Imports physiological measurements from a scanner log
%
%   EEGSET_OBJ = import_scanner_log(EEGSET_OBJ, LOGFILE) imports data from 
%   log file LOGFILE into the eegset object EEGSET_OBJ. The physiological
%   measurements will be stored in the property physiology while any
%   relevant marks in the log file (e.g. R-peaks) will be added to the
%   Event property of the output eegset object.
%
% See also +EEGC

error('This function does not work yet!!');

import spt.pca;
import spt.TRANSFORM.multicombi;
import spt.criterion.acf;
import misc.process_varargin;
import misc.dlmread;
import misc.center;
import misc.peak_find;

% Options accepted by this function
THIS_OPTIONS = {'logsamplingrate', 'trevent', 'nslices', 'tr', 'verbose'};

% Default options
trevent = 'TR Pulse';
logsamplingrate = 512;
tr = [];
nslices = 40;
verbose = true;

eval(process_varargin(THIS_OPTIONS, varargin));


% TR and slice duration
ev_array = eegset_obj.Event;
tr_eeg_loc = cell2mat(get(ev_array(ev_array == trevent), 'Sample'));
if ~isempty(tr),
    tr = round(tr*samplingrate*1e-3);
else
    % guess the TR from the EEG events
    tr = median(diff(tr_eeg_loc));
end
tr_log = round((tr/eegset_obj.SamplingRate)*logsamplingrate);
slice_dur = floor(tr/nslices);
slice_dur_log = round(slice_dur/(eegset_obj.SamplingRate/logsamplingrate));

% Epoch of interest spans from first TR to last slice (+a margin of 3 TRs)
last = min(tr_eeg_loc(end)+tr*3, eegset_obj.NbPoints);
first = max(1, tr_eeg_loc(1)-tr*3);
epoch_duration = (last-first+1)/eegset_obj.SamplingRate;
epoch_duration_log = ceil(epoch_duration*logsamplingrate);

% Read the scanner log file
data = dlmread(logfile, [], 5, 0, 'CommentStyle', '#');
stop = find(data(:, end) == 20);
if isempty(stop),
    error('');
else
    stop = stop(end);
end
epoch_duration_log = min(stop, epoch_duration_log);
epoch_duration = round((epoch_duration_log/logsamplingrate)*eegset_obj.SamplingRate);
data2match = data(stop-epoch_duration_log+1:stop,:);
grad = center(data2match(:,end-3:end-1)');
grad_orig = pca(grad,[],1);

% Find a TR-related independent component
spf_obj = spt.TRANSFORM.multicombi('EmbedDim', min(20,floor(slice_dur/5)));
spf_obj = learn(spf_obj, grad);
y = project(spf_obj, grad);
smoothingorder = ceil(slice_dur_log/2);
sel_criterion = spt.criterion.acf('Lag', tr_log, ...
    'SmoothingOrder', smoothingorder, ...
    'Type', 'none', ...
    'NbComp', 1);
idx = select(sel_criterion, y);
grad = filter(spf_obj, grad, idx);


% Find preliminary locations of the TRs
b = (1/smoothingorder)*ones(1,smoothingorder);
grad = filter(b, 1, sum(grad.^2));
grad(grad<.1*max(grad))=0;
maxtab = peak_find(grad,'delta', 2,...
    'meandist', tr_log, ...
    'madth', 0.1, ...
    'type','max');    

% Actual TR locations correspond to the first negative peak of the gradient
for i = 1:size(maxtab,1)
    first = max(1,maxtab(i,1)-slice_dur_log);
    last = min(maxtab(i,1)+slice_dur_log, length(grad));
    this_grad = grad_orig(first:last);
    this_maxtab = peak_find(this_grad,'delta', 2,...
    'type','min');
    if size(this_maxtab,1)>1, 
        index = first:last;        
        maxtab(i,1) = index(this_maxtab(1,1));
        maxtab(i,2) = this_maxtab(1,2);        
    end
end
tr_loc_log = maxtab(:,1)';

% Make the sampling frequencies of log file and EEG file match
if eegset_obj.SamplingRate > logsamplingrate,
    fs = eegset_obj.SamplingRate;
    factor = eegset_obj.SamplingRate/logsamplingrate;    
    tr_loc_log = round(factor*tr_loc_log);
else
    error('not implemented yet');
end

% Locate a Gaussian bell at the location of each EEG event
ev_train = zeros(1, tr_eeg_loc(end));
ev_train(tr_eeg_loc)=1;
sigma_samples = round(.9*slice_dur);
sigma = sigma_samples/fs; 
range = -4*sigma_samples:4*sigma_samples;
gauss_bell = (1/(2*pi*sigma^2))*exp(-range.^2/(2*(sigma_samples)^2));
ev_train = conv(ev_train, gauss_bell);

% Create a similar train of events based on the log file gradient info
tr_loc_log_first = tr_loc_log(1);
tr_loc_log = tr_loc_log - tr_loc_log_first + 1;
ev_train_log = zeros(1, tr_loc_log(end));
ev_train_log(tr_loc_log) = 1;
ev_train_log = conv(ev_train_log, gauss_bell);
[c,lags] = xcorr(ev_train, ev_train_log);
[~, idx] = max(c);
shift = lags(idx);
% tr_loc = tr_loc_log+shift; FINNISH THIS!
% tr_loc_log = tr_loc_log + tr

caca=5;


