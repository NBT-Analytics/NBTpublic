function delay = delay_guess(y, a, nb_lags, varargin)
% delay_guess - Guesses the delay between two data matrices
%
%

import misc.globals;
import misc.process_varargin;

% Process varargin
THIS_OPTIONS = {'verbose', 'maxnbchans'};
maxnbchans =  min(ceil((globals.evaluate.NbChans4DelayCorr/100)*size(y,1)),...
    ceil((globals.evaluate.NbChans4DelayCorr/100)*size(a,1)));
verbose = globals.evaluate.Verbose;
eval(process_varargin(THIS_OPTIONS, varargin));

nb_idx = min([size(y,1), max(1,maxnbchans), size(a,1)]);
idx = randperm(min(size(y,1),size(a,1)));
idx = idx(1:nb_idx);

c = zeros(1, 2*nb_lags+1);
for i = 1:nb_idx
    
    w1 = zeros(1, size(y,1));
    w2 = zeros(1, size(a,1));
    w1(idx(i)) = 1;
    w2(idx(i)) = 1;
    [this_c, lags] = xcorr(w1*y, w2*a, nb_lags);
    c = c + this_c;
    if verbose,
        fprintf('.');
    end
    
end
[~, max_lag] = max(abs(c));
delay = lags(max_lag);

