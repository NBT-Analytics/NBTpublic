% Copyright (C) 2010  Neuronal Oscillations and Cognition group, Department of Integrative Neurophysiology, Center for Neurogenomics and Cognitive Research, Neuroscience Campus Amsterdam, VU University Amsterdam.
%
% Part of the Neurophysiological Biomarker Toolbox (NBT)
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
%
% See Readme.txt for additional copyright information.
%

% ChangeLog - see version control log for details
% <date> - Version <#> - <text>

function nbt_eegplot(EEG)

res = inputgui('geometry', { 1 1 1 1}, 'uilist', ...
    { { 'style' 'text' 'string' 'Channels to view' } { 'style' 'edit' 'string' '' } { 'style' 'text' 'string' 'Re-reference to' } ...
    { 'style' 'edit' 'string' '' } }, 'title', 'nbt_eegplot');

if(isempty(res))
    return
end
try
EEG = eeg_interp(EEG, find(EEG.NBTinfo.BadChannels));
catch
end

EEG = nbt_ReRef(EEG, str2num(res{2}));
%EEG = pop_iirfilt(EEG);
data = EEG.data;
% disp('PCA...')
% [eigvec,eigval,EEG.data] = pcsquash(EEG.data,size(EEG.data,1));
% EEG.data = eigvec(:,2:end)'*data;
% EEG.data= pcexpand(EEG.data,eigvec,mean(data'));
EEG.data = EEG.data(str2num(res{1}),:);
EEG.chanlocs = EEG.chanlocs(str2num(res{1}));
EEG.nbchan  = size(EEG.data,1);
%EEG = pop_iirfilt(EEG);
 disp('High-pass filter 0.5 Hz - low-pass filter 45 Hz')
 data = nbt_filter_fir(EEG.data',0.5,45,EEG.srate,4);
 % adjust filter offset
 disp('adjusting filter offset 2000 ms')
 EEG.data = data((2*EEG.srate):end,:)';
 
 
 posA =nbt_highdiff(data(2*EEG.srate:end,:));
 m=0;
 for ii=(length(EEG.event)+1):2:(length(posA)*2+(length(EEG.event)))
     m=m+1;
     EEG.event(ii).type = 'possible artifact';
     EEG.event(ii).latency = posA(m);
     EEG.event(ii).position = ii;
     EEG.event(ii).duration = 500;
     
     EEG.event(ii+1).type = 'possible artifact';
     EEG.event(ii+1).latency = posA(m)+500;
     EEG.event(ii+1).position = ii+1;
     EEG.event(ii+1).duration = 500;
 end
 %%exp stuff
 data = nbt_filter_fir(data,8,13,EEG.srate,0.36);
ampalpha = median(abs(hilbert(data(:,:))),2);
m=0;
for ii=1:20000:length(ampalpha)-20000
m = m+1;
vvf(m) = median(ampalpha(ii:ii+20000))/median(ampalpha);
end
posS = find(vvf<0.8);
posS = (posS-1)*20000;

m=0;
 for ii=(length(EEG.event)+1):(length(posS)+(length(EEG.event)))
     m=m+1;
     EEG.event(ii).type = 'Sleep?';
     EEG.event(ii).latency = posS(m);
     EEG.event(ii).position = ii;
     EEG.event(ii).duration = 100;
 end
%% exp stuff end
 clear data
pop_eegplot(EEG);
end
