% helper function, to filter using the firls function.
% this automatically sets all the complicated settings.
% then, i don't have to repeat the process.
%
% function out = helper_filter(in,freq,fs,hl)
%
% in = your to-be filtered vector (1xN or Nx1)
% freq = cut-off frequency
% fs = sampling frequency
% hl = 'high' or 'low', depending on whether you want high/low pass filter.
%
% In the low-pass setting, the filter order is set so that the highest
% frequency oscillation of the pass-band has a little more than 6 data
% points.
%
% In the high-pass setting, the filter order is set so that the
% lowest-frequency oscillation of the pass-band lasts about 3 data points.
function out = helper_filter(in,freq,fs,hl)


if nargin<4
    error('you should provide 4 arguments to this function; v, freq, fs, hl.');
end

if size(in, 1) > 1,
    error('A single ECG channel is expected as input');
end


trans=0.15;
nyq=fs/2;
option=hl;



if strcmpi(option,'high');
    
    filtorder=round(1.2*fs/freq/(1-trans));

    f=[0  freq*(1-trans)/nyq  freq/nyq  1];
    
    a=[0 0 1 1];
    
end


if strcmpi(option,'low')

	filtorder=3*fix(fs/freq);

    f=[0  freq/nyq freq*(1+trans)/nyq  1];
    
    a=[1 1 0 0];
    
end


if rem(filtorder,2)~=0
    filtorder=filtorder+1;
end

try
fwts=firls(filtorder,f,a);
catch
    keyboard;
end

out=filtfilt(fwts,1,in);




% if verbosity
%     
%     figure;
%     freqz(fwts,1,nyq,fs);
%     figure;plot(in);
%     hold on;
%     plot(out,'r');
%     legend({'in','out'});
% 
% end
    
    



